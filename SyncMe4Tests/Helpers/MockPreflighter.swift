@testable import SyncMe4
import AppKit

final class MockPreflighter: PreflighterType {
    var methodsCalled = [String]()
    var folder1: URL?
    var folder2: URL?
    var entries = [Entry]()

    func compareFolders(folder1: URL, folder2: URL) async throws -> [Entry] {
        methodsCalled.append(#function)
        self.folder1 = folder1
        self.folder2 = folder2
        return entries
    }
}
