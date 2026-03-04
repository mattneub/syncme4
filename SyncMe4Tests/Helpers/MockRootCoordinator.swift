@testable import SyncMe4
import AppKit

final class MockRootCoordinator: RootCoordinatorType {
    var methodsCalled = [String]()
    var window: NSWindow?

    func createMainModule(window: NSWindow) {
        methodsCalled.append(#function)
        self.window = window
    }

    func showPrefs() {
        methodsCalled.append(#function)
    }

    func closePrefs() {
        methodsCalled.append(#function)
    }

    func destroyPrefs() {
        methodsCalled.append(#function)
    }

    func showLog() {
        methodsCalled.append(#function)
    }

    func closeLog() {
        methodsCalled.append(#function)
    }

    func destroyLog() {
        methodsCalled.append(#function)
    }

}
