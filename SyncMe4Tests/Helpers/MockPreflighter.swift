@testable import SyncMe4
import AppKit

@Observable
final class MockPreflighter: PreflighterType {
    nonisolated(unsafe) var currentFolder: String?
    @ObservationIgnored nonisolated(unsafe) var methodsCalled = [String]()
    @ObservationIgnored nonisolated(unsafe) var folder1: URL?
    @ObservationIgnored nonisolated(unsafe) var folder2: URL?
    @ObservationIgnored nonisolated(unsafe) var stopList: [String]?
    @ObservationIgnored nonisolated(unsafe) var entries = [Entry]()
    @ObservationIgnored nonisolated(unsafe) var folders = [String]()
    @ObservationIgnored nonisolated(unsafe) var error: (any Error)?

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
