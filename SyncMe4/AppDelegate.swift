import Cocoa
//import SwiftAutomation
//import MacOSGlues

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
            contentRect: NSRect(x: 0, y: 0, width: 660, height: 432),
            styleMask: [.miniaturizable, .closable, .titled, .resizable],
            backing: .buffered,
            defer: false
        )
        rootCoordinator.createMainModule(window: window)
        window.center()
        window.isReleasedWhenClosed = false
        window.title = "SyncMe4"
        window.minSize = CGSize(width: 660, height: 432)
        window.makeKeyAndOrderFront(nil)
        // window.setFrameAutosaveName("SyncMe4_Main_Window")
        // hook Option menu to our "manual binding" system
        // NSApplication.shared.mainMenu?.item(withTitle: "Option")?.submenu?.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        unlessTesting(true)
    }
}
