@testable import SyncMe4

final class MockApplication: ApplicationType {
    var methodsCalled = [String]()

    func terminate(_: Any?) {
        methodsCalled.append(#function)
    }
}
