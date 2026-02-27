@testable import SyncMe4
import Foundation

final class MockFinderScripter: FinderScripterType {
    var methodsCalled = [String]()
    var url: URL?

    func tickle() {
        methodsCalled.append(#function)
    }

    func reveal(_ url: URL) {
        methodsCalled.append(#function)
        self.url = url
    }
}
