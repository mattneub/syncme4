import AppKit

protocol RootCoordinatorType: AnyObject {
    func createMainModule(window: NSWindow)
    func showPrefs()
    func closePrefs()
    func destroyPrefs()
}

final class RootCoordinator: RootCoordinatorType {
    weak var mainViewController: NSViewController?

    /// Window controllers must be maintained, or they and their dependents will vanish.
    var prefsWindowController: NSWindowController?

    /// In case we need to know where the main window is, or bring it to the front.
    weak var mainWindow: NSWindow?

    var mainProcessor: (any Processor<MainAction, MainState, MainEffect>)?
    var prefsProcessor: (any Processor<PrefsAction, PrefsState, PrefsEffect>)?

    func createMainModule(window: NSWindow) {
        let processor = MainProcessor()
        self.mainProcessor = processor
        processor.coordinator = self
        let viewController = MainViewController()
        processor.presenter = viewController
        viewController.processor = processor
        self.mainViewController = viewController
        window.contentViewController = viewController
        self.mainWindow = window
    }

    func showPrefs() {
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
        window?.center()
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
    }
}
