import AppKit

final class PrefsWindowController: NSWindowController {
    weak var coordinator: (any RootCoordinatorType)?

    override var windowNibName: NSNib.Name? { "Prefs" }

    @IBOutlet var viewController: PrefsViewController!

    override func windowDidLoad() {
        window?.contentViewController = viewController // cannot be configured in nib (it's a storyboard relationship)
    }

    deinit {
        print("farewell from prefs window controller")
    }
}

extension PrefsWindowController: NSWindowDelegate { // configured as delegate in nib
    /// Help coordinator do management; it will nilify its reference to us, releasing
    /// the window controller and the view controller.
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        coordinator?.destroyPrefs()
        return true
    }
}
