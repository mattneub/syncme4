@testable import SyncMe4

final class MockBeeper: BeeperType {
    var methodsCalled = [String]()

    func beep() {
        methodsCalled.append(#function)
    }
}
