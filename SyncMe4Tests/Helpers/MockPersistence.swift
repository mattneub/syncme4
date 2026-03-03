@testable import SyncMe4
import AppKit

final class MockPersistence: PersistenceType {
    var methodsCalled = [String]()
    var stopList = [String]()

    func registerDefaults() {
        methodsCalled.append(#function)
    }

    func loadStopList() -> [String] {
        methodsCalled.append(#function)
        return stopList
    }

    func saveStopList(_ list: [String]) {
        methodsCalled.append(#function)
        stopList = list
    }

}
