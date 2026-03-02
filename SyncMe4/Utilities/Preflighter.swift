import AppKit

protocol PreflighterType {
    var currentFolder: String? { get }
    func prepare()
    func compareFolders(folder1: URL, folder2: URL, stopList: [String]) async throws -> [Entry]
}

@Observable
nonisolated
final class Preflighter: PreflighterType {
    /// Observable value of the folder we are currently considering.
    nonisolated var currentFolder: String?

    /// Public method. An observer must call this before starting to observe, so that it does
    /// not immediately see `nil` as the current folder, because `nil` is the signal we've finished.
    func prepare() {
        currentFolder = ""
    }

    /// Public method. The strategy is to make the comparison in two passes: in the first pass,
    /// we discover items that exist in folder1 that do not exist in folder2, and in the second,
    /// we discover items that exist in folder2 that do not exist in folder1. In the first pass,
    /// we also discover items that exist in both folder1 and folder2 and decide which way (if any)
    /// to copy; there is no point doing that during the second pass as well, since it's exactly
    /// the same set of items, so we use the `firstPass` flag to tell the workhorse methods
    /// to skip that part if it's not the first pass.
    /// - Parameters:
    ///   - folder1: First (left, during first pass) folder to compare.
    ///   - folder2: Second (right, during first pass) folder to compare.
    /// - Returns: List of Entry objects, each describing a needed copy operation if the folders
    /// are to be made identical.
    @concurrent
    func compareFolders(folder1: URL, folder2: URL, stopList: [String]) async throws -> [Entry] {
        var list = [Entry]()
        try await listInto(&list, withFolder: folder1, withFolder: folder2, firstPass: true, stopList: stopList)
        try await listInto(&list, withFolder: folder2, withFolder: folder1, firstPass: false, stopList: stopList)
        currentFolder = nil // signal finished
        await Task.yield()
        return list
    }

    /// The workhorse method, called twice as explained in the discussion of `compareFolders`.
    /// - Parameters:
    ///   - theList: Inout reference to a list of Entry that we can append to.
    ///   - folder1: The source folder, all of whose contents are to be examined.
    ///   - folder2: The destination folder, where we will look to see if an item matches each
    ///   item of the source.
    ///   - firstPass: Whether this is the first pass, when we will also compare dates on items
    ///   that appear in both folders.
    ///   - stopList: Filenames to ignore.
    nonisolated
    func listInto(
        _ theList: inout [Entry],
        withFolder folder1: URL,
        withFolder folder2: URL,
        firstPass: Bool,
        stopList: [String]
    ) async throws {
        currentFolder = folder1.path(percentEncoded: false)
        await Task.yield()
        var keys: Set<URLResourceKey> = [
            .isDirectoryKey, .isPackageKey, .isAliasFileKey, .isSymbolicLinkKey
        ]
        if firstPass {
            keys.insert(.contentModificationDateKey)
        }
        let contents = try FileManager.default.contentsOfDirectory(at: folder1, includingPropertiesForKeys: Array(keys))
        for item in contents {
            try? await ifTesting {
                try? await Task.sleep(for: .seconds(0.2))
            }
            try Task.checkCancellation()
            let itemVals = try item.resourceValues(forKeys: Set(keys))
            if let isAlias = itemVals.isAliasFile, isAlias { continue }
            if let isLink = itemVals.isSymbolicLink, isLink { continue }
            // skip items whose name is in the stop list
            if stopList.contains(item.lastPathComponent) { continue }
            // okay, ready to do some actual work!
            // if item doesn't exist in clone, add an entry for it
            guard let itemIsDir = itemVals.isDirectory else { continue }
            let cloneItem = folder2.appending(path: item.lastPathComponent, directoryHint: itemIsDir ? .isDirectory : .notDirectory)
            let cloneItemExists = (try? cloneItem.checkResourceIsReachable()) == true
            if !cloneItemExists {
                let why: Reason = firstPass ? .absentRight : .absentLeft
                theList.append(Entry(copyFrom: item, copyTo: cloneItem, why: why))
                continue
            }
            // so, it exists; if both are directories and neither is a package, recurse into both directories
            let cloneVals = try cloneItem.resourceValues(forKeys: Set(keys))
            guard let cloneItemIsDir = cloneVals.isDirectory else { continue }
            if itemIsDir && cloneItemIsDir {
                guard let itemIsPackage = itemVals.isPackage else { continue }
                guard let cloneItemIsPackage = cloneVals.isPackage else { continue }
                if !itemIsPackage && !cloneItemIsPackage {
                    try await listInto(&theList, withFolder: item, withFolder: cloneItem, firstPass: firstPass, stopList: stopList)
                    continue
                }
            }
            // so they are not both directories;
            // if we're not comparing dates, don't go any further, we've finished with this pair
            if !firstPass { continue }
            // make absolutely sure they are both normal files
            guard !itemIsDir && !cloneItemIsDir else { continue }
            if let isAlias = cloneVals.isAliasFile, isAlias { continue }
            if let isLink = cloneVals.isSymbolicLink, isLink { continue }
            // okay, item exists in both places and is a normal file and we're comparing dates;
            // so compare them!
            guard let itemDate = itemVals.contentModificationDate else { continue }
            guard let cloneDate = cloneVals.contentModificationDate else { continue }
            if itemDate == cloneDate {
                continue // nothing to do
            }
            if itemDate > cloneDate {
                let why: Reason = firstPass ? .olderRight : .olderLeft
                theList.append(Entry(copyFrom: item, copyTo: cloneItem, why: why))
            } else {
                let why: Reason = firstPass ? .olderLeft : .olderRight
                theList.append(Entry(copyFrom: cloneItem, copyTo: item, why: why))
            }
        }
    }
}
