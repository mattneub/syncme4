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

    @Test("closePrefs: tells window controller to close, then same as destroyPrefs")
    func closePrefs() {
        let windowController = MockWindowController()
        subject.prefsWindowController = windowController
        subject.prefsProcessor = PrefsProcessor()
        subject.closePrefs()
        #expect(windowController.methodsCalled == ["close()"])
        #expect(subject.prefsWindowController == nil)
        #expect(subject.prefsProcessor == nil)
    }

    @Test("destroyPrefs: nilifies the prefs window controller")
    func destroyPrefs() {
        let windowController = MockWindowController()
        subject.prefsProcessor = PrefsProcessor()
        subject.prefsWindowController = windowController
        subject.destroyPrefs()
        #expect(subject.prefsWindowController == nil)
        #expect(subject.prefsProcessor == nil)
    }

    @Test("showLog: creates the log module")
    func showLog() throws {
        subject.showLog()
        let windowController = try #require(subject.logWindowController as? LogWindowController)
        #expect(windowController.coordinator === subject)
        #expect(windowController.isWindowLoaded)
        let viewController = try #require(windowController.viewController)
        let processor = try #require(subject.logProcessor as? LogProcessor)
        #expect(processor.coordinator === subject)
        #expect(processor.presenter === viewController)
        #expect(viewController.processor === processor)
        #expect(windowController.window?.isVisible == true)
        closeWindows()
    }

    @Test("closeLog: tells window controller to close, then same as destroyLog")
    func closeLog() {
        let windowController = MockWindowController()
        subject.logWindowController = windowController
        subject.logProcessor = LogProcessor()
        subject.closeLog()
        #expect(windowController.methodsCalled == ["close()"])
        #expect(subject.logWindowController == nil)
        #expect(subject.logProcessor == nil)
    }

    @Test("destroyLog: nilifies the log window controller")
    func destroyLog() {
        let windowController = MockWindowController()
        subject.logProcessor = LogProcessor()
        subject.logWindowController = windowController
        subject.destroyLog()
        #expect(subject.logWindowController == nil)
        #expect(subject.logProcessor == nil)
    }
}

private final class MockWindowController: NSWindowController {
    var methodsCalled = [String]()

    override func close() {
        methodsCalled.append(#function)
    }
}
