@testable import SyncMe4
import AppKit

final class MockMainDatasource: NSObject, @MainActor TableViewDatasourceType {
    typealias State = MainState
    typealias Received = Void
    var statePresented: MainState?
    var methodsCalled = [String]()

    func present(_ state: MainState) async {
        methodsCalled.append(#function)
        self.statePresented = state
    }
}
