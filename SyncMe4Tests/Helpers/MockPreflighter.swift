@testable import SyncMe4
import AppKit

@Observable
final class MockPreflighter: PreflighterType {
    var currentFolder: String?
    var methodsCalled = [String]()
    var folder1: URL?
    var folder2: URL?
    var entries = [Entry]()
    var folders = [String]()

    func prepare() {
        methodsCalled.append(#function)
    }

    func compareFolders(folder1: URL, folder2: URL) async throws -> [Entry] {
        methodsCalled.append(#function)
        self.folder1 = folder1
        self.folder2 = folder2
        while !folders.isEmpty {
            currentFolder = folders.popLast()
            try? await Task.sleep(for: .seconds(0.1))
        }
        currentFolder = nil
        try? await Task.sleep(for: .seconds(0.1))
        return entries
    }
}
