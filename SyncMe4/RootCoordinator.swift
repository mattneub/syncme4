import AppKit

protocol RootCoordinatorType: AnyObject {
    func createMainModule(window: NSWindow)
    func showPrefs()
    func closePrefs()
    func destroyPrefs()
    func showLog()
    func closeLog()
    func destroyLog()
}

final class RootCoordinator: RootCoordinatorType {

    /// Window controllers must be maintained, or they and their dependents will vanish.
    var prefsWindowController: NSWindowController?
    var logWindowController: NSWindowController?

    var mainProcessor: (any Processor<MainAction, MainState, MainEffect>)?
    var prefsProcessor: (any Processor<PrefsAction, PrefsState, PrefsEffect>)?
    var logProcessor: (any Processor<LogAction, LogState, Void>)?

    func createMainModule(window: NSWindow) {
        let processor = MainProcessor()
        self.mainProcessor = processor
        processor.coordinator = self
        let viewController = MainViewController()
        processor.presenter = viewController
        viewController.processor = processor
        window.contentViewController = viewController
    }

    func showPrefs() {
        guard prefsWindowController == nil else {
            return
        }
        let windowController = PrefsWindowController()
        windowController.coordinator = self
        let window = windowController.window // causes nib to load
        let viewController = windowController.viewController // created and connected in window nib
        let processor = PrefsProcessor()
        prefsProcessor = processor
        processor.coordinator = self
        processor.presenter = viewController
        viewController?.processor = processor
        prefsWindowController = windowController
        window?.makeKeyAndOrderFront(self)
    }

    func closePrefs() {
        if let windowController = prefsWindowController {
            windowController.close()
            destroyPrefs()
        }
    }

    func destroyPrefs() {
        prefsWindowController = nil // releases view controller too, if loading happened correctly
        prefsProcessor = nil
    }

    func showLog() {
        guard logWindowController == nil else {
            return
        }
        let windowController = LogWindowController()
        windowController.coordinator = self
        let window = windowController.window // causes nib to load
        let viewController = windowController.viewController // created and connected in window nib
        let processor = LogProcessor()
        logProcessor = processor
        processor.coordinator = self
        processor.presenter = viewController
        viewController?.processor = processor
        logWindowController = windowController
        window?.makeKeyAndOrderFront(self)
    }

    func closeLog() {
        if let windowController = logWindowController {
            windowController.close()
            destroyLog()
        }
    }

    func destroyLog() {
        logWindowController = nil // releases view controller too, if loading happened correctly
        logProcessor = nil
    }

}
