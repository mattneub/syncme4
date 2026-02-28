@testable import SyncMe4
import Foundation

final class MockFinderScripter: FinderScripterType {
    nonisolated(unsafe) var methodsCalled = [String]()
    nonisolated(unsafe) var urls = [URL]()
    nonisolated(unsafe) var errorToThrow: (any Error)?

    func tickle() {
        methodsCalled.append(#function)
    }

    func reveal(_ url: URL) {
        methodsCalled.append(#function)
        self.urls.append(url)
    }

    func trash(_ url: URL) throws {
        methodsCalled.append(#function)
        self.urls.append(url)
        if let errorToThrow {
            throw errorToThrow
        }
    }

}
