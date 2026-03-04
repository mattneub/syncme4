import AppKit

final class LogWindowController: NSWindowController {
    weak var coordinator: (any RootCoordinatorType)?

    override var windowNibName: NSNib.Name? { "Log" }

    @IBOutlet var viewController: LogViewController!

    override func windowDidLoad() {
        window?.contentViewController = viewController // cannot be configured in nib (it's a storyboard relationship)
    }

    deinit {
        print("farewell from log window controller")
    }
}

extension LogWindowController: NSWindowDelegate { // configured as delegate in nib
    /// Help coordinator do management; it will nilify its reference to us, releasing
    /// the window controller and the view controller.
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        coordinator?.destroyLog()
        return true
    }
}
