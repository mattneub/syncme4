import Cocoa

@MainActor
var services = Services()

class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!

    var rootCoordinator: any RootCoordinatorType = RootCoordinator()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        unlessTesting {
            bootstrap()
        }
    }

    func bootstrap() {
        // The Empty.xib file prevents automatic finding of the MainMenu.xib file,
        // so we can now load it ourselves as part of the bootstrap
        // but I don't want to do that even when testing this method, because of the massive console dump it causes
        unlessTesting {
            Bundle.main.loadNibNamed("MainMenu", owner: NSApplication.shared, topLevelObjects: nil)
        }
        // create the window _after_ loading the menu, so that it gets registered into the window menu
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 682, height: 450),
            styleMask: [.miniaturizable, .closable, .titled, .resizable],
            backing: .buffered,
            defer: false
        )
        rootCoordinator.createMainModule(window: window)
        window.center()
        window.isReleasedWhenClosed = false
        window.title = "SyncMe4"
        window.minSize = CGSize(width: 682, height: 450 + 32)
        window.maxSize = CGSize(width: 10000, height: 10000)
        window.makeKeyAndOrderFront(nil)
        services.persistence.registerDefaults()
        // window.setFrameAutosaveName("SyncMe4_Main_Window")
        // target the help menu item at the app delegate, since first responder targeting doesn't seem to work here
        NSApplication.shared.mainMenu?.item(withTitle: "Help")?.submenu?.item(at: 0)?.target = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        unlessTesting(true)
    }

    @objc func doPrefs(_ sender: Any) {
        rootCoordinator.showPrefs()
    }

    @objc func showHelp(_ sender: Any) {
        if let url = services.bundle.url(forResource: "help", withExtension: "html", subdirectory: "help") {
            _ = services.workspace.open(url)
        }
    }

    @objc func showLogWindow(_ sender: Any) {
        rootCoordinator.showLog()
    }

    // By playing around with this, I discovered that this instance was being destroyed and another
    // instance substituted for it, in a way that broke the nil-targeted action chain and also meant
    // that `shouldTerminate` was not being obeyed. But where did the other instance come from?
    // It's really hard to say; I think it was being created in MainMenu.xib, but I could not
    // understand why it was being substituted for this instance. Anyway, deleting it from
    // MainMenu.xib fixed the problem.
    deinit {
        print("farewell from app delegate", self)
    }

}
