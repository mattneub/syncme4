import AppKit

protocol RootCoordinatorType: AnyObject {
    func createMainModule(window: NSWindow)
}

final class RootCoordinator: RootCoordinatorType {
    weak var mainViewController: NSViewController?

    /// In case we need to know where the main window is, or bring it to the front.
    weak var mainWindow: NSWindow?

    var mainProcessor: (any Processor<MainAction, MainState, Void>)?

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

}
