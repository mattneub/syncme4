@testable import SyncMe4
import AppKit

@Observable
final class MockPreflighter: PreflighterType {
    var currentFolder: String?
    @ObservationIgnored var methodsCalled = [String]()
    @ObservationIgnored var folder1: URL?
    @ObservationIgnored var folder2: URL?
    @ObservationIgnored var stopList: [String]?
    @ObservationIgnored var entries = [Entry]()
    @ObservationIgnored var folders = [String]()
    @ObservationIgnored var error: (any Error)?

    func prepare() {
        methodsCalled.append(#function)
    }

    func compareFolders(folder1: URL, folder2: URL, stopList: [String]) async throws -> [Entry] {
        methodsCalled.append(#function)
        self.folder1 = folder1
        self.folder2 = folder2
        self.stopList = stopList
        while !folders.isEmpty {
            currentFolder = folders.popLast()
            try? await Task.sleep(for: .seconds(0.1))
        }
        if let error {
            throw error
        }
        currentFolder = nil
        try? await Task.sleep(for: .seconds(0.1))
        return entries
    }
}
