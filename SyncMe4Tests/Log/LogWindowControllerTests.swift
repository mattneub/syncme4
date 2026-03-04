import Testing
@testable import SyncMe4
import AppKit

private struct LogWindowControllerTests: ~Copyable {
    let subject = LogWindowController()
    let coordinator = MockRootCoordinator()

    init() {
        subject.coordinator = coordinator
    }

    deinit {
        closeWindows()
    }

    @Test("windowNibName: is correct")
    func windowNibName() {
        #expect(subject.windowNibName == "Log")
    }

    @Test("the nib loads correctly")
    func loads() {
        let window = subject.window
        #expect(subject.viewController != nil)
        #expect(window?.contentViewController === subject.viewController)
        #expect(window?.delegate === subject)
    }

    @Test("shouldClose: calls coordinator destroyPrefs, returns true")
    func shouldClose() {
        let result = subject.windowShouldClose(NSWindow())
        #expect(coordinator.methodsCalled == ["destroyLog()"])
        #expect(result == true)
    }
}
