@testable import SyncMe4
import AppKit

final class MockPrefsDatasource: NSObject, @MainActor TableViewDatasourceType {
    typealias State = PrefsState
    typealias Received = PrefsEffect
    var statePresented: PrefsState?
    var methodsCalled = [String]()
    var thingsReceived = [PrefsEffect]()

    func present(_ state: PrefsState) async {
        methodsCalled.append(#function)
        self.statePresented = state
    }

    func receive(_ effect: PrefsEffect) async {
        methodsCalled.append(#function)
        self.thingsReceived.append(effect)
    }
}
