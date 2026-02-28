import Foundation

/// An Entry is a single operation-to-be-performed; this what preflighting creates a list of,
/// and thus is also what is represented by the preflight table, and at the same time it states
/// what to do when the time comes to perform the action.
nonisolated struct Entry: Equatable {
    // unique id so that we can use a diffable data source

    let id = UUID()

    // Actual item URLs

    var copyFrom: URL // item that is source
    var copyTo: URL // item that is destination

    var why: Reason // var, because we can change reason later

    // Paths directly from source / destination urls

    var sourcePath: String {
        copyFrom.path(percentEncoded: false)
    }

    var destinationPath: String {
        copyTo.path(percentEncoded: false)
    }

    // Directional (spatial) representations to show the user the pathnames
    // in the left folder and the right folder, respectively.

    var leftFolderItemPath: String {
        (why.direction == .leftToRight ? sourcePath : destinationPath)
    }

    var rightFolderItemPath: String {
        (why.direction == .leftToRight ? destinationPath : sourcePath)
    }

    // Index number so we can restore the original sort order
    var originalOrder = 0

    init(copyFrom: URL, copyTo: URL, why: Reason) {
        self.copyFrom = copyFrom
        self.copyTo = copyTo
        self.why = why
    }
}
