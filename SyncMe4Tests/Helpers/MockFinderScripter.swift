@testable import SyncMe4

final class MockFinderScripter: FinderScripterType {
    var methodsCalled = [String]()

    func tickle() {
        methodsCalled.append(#function)
    }
}
