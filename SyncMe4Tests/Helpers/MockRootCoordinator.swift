@testable import SyncMe4
import AppKit

final class MockRootCoordinator: RootCoordinatorType {
    var methodsCalled = [String]()
    var window: NSWindow?

    func createMainModule(window: NSWindow) {
        methodsCalled.append(#function)
        self.window = window
    }
}
