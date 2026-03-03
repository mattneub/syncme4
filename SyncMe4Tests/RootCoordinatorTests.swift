import Testing
@testable import SyncMe4
import AppKit
import WaitWhile

private struct RootCoordinatorTests: ~Copyable {
    let subject = RootCoordinator()

    deinit {
        closeWindows()
    }

    @Test("createMainModule: creates the main module")
    func createMainModule() throws {
        let window = makeWindow(viewController: NSViewController())
        subject.createMainModule(window: window)
        let processor = try #require(subject.mainProcessor as? MainProcessor)
        #expect(processor.coordinator === subject)
        let viewController = try #require(processor.presenter as? MainViewController)
        #expect(viewController.processor === processor)
        #expect(subject.mainViewController === viewController)
        #expect(window.contentViewController === viewController)
    }

    @Test("showPrefs: creates the prefs module")
    func showPrefs() throws {
        subject.showPrefs()
        let windowController = try #require(subject.prefsWindowController as? PrefsWindowController)
        #expect(windowController.coordinator === subject)
        #expect(windowController.isWindowLoaded)
        let viewController = try #require(windowController.viewController)
        let processor = try #require(subject.prefsProcessor as? PrefsProcessor)
        #expect(processor.coordinator === subject)
        #expect(processor.presenter === viewController)
        #expect(viewController.processor === processor)
        #expect(windowController.window?.isVisible == true)
        closeWindows()
    }

    @Test("destroyPrefs: nilifies the prefs window controller")
    func destroyPrefs() {
        let windowController = PrefsWindowController()
        subject.prefsWindowController = windowController
        subject.destroyPrefs()
        #expect(subject.prefsWindowController == nil)
    }
}
