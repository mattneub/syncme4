import Testing
@testable import SyncMe4
import AppKit

private struct AppDelegateTests: ~Copyable {
    deinit {
        closeWindows()
    }

    @Test("bootstrap: creates and configures the main window; calls root coordinator createMainModule")
    func bootstrap() throws {
        let coordinator = MockRootCoordinator()
        let subject = AppDelegate()
        subject.rootCoordinator = coordinator
        subject.bootstrap()
        let window = try #require(subject.window)
        #expect(window.title == "SyncMe4")
        #expect(window.isReleasedWhenClosed == false)
        #expect(window.styleMask == [.miniaturizable, .closable, .titled, .resizable])
        #expect(window.frame.size == CGSize(width: 682, height: 450 + 32)) // title bar height
        #expect(window.minSize == window.frame.size)
        #expect(window.maxSize == CGSize(width: 10000, height: 10000))
        // I don't want to run this code even when testing bootstrap, so I've wrapped `unlessTesting` around it
        // #expect(NSApplication.shared.mainMenu != nil)
        #expect(coordinator.methodsCalled == ["createMainModule(window:)"])
        #expect(coordinator.window === window)
    }
}


