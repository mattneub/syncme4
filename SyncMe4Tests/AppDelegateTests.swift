import Testing
@testable import SyncMe4
import AppKit

private struct AppDelegateTests: ~Copyable {
    deinit {
        closeWindows()
    }

    @Test("bootstrap: creates and configures the main window; calls root coordinator createMainModule, registers defaults")
    func bootstrap() throws {
        let persistence = MockPersistence()
        services.persistence = persistence
        let coordinator = MockRootCoordinator()
        let subject = AppDelegate()
        subject.rootCoordinator = coordinator
        subject.bootstrap()
        let window = try #require(subject.window)
        #expect(window.title == "SyncMe4")
        #expect(window.isReleasedWhenClosed == false)
        #expect(window.styleMask == [.miniaturizable, .closable, .titled, .resizable])
        #expect(window.frame.size == CGSize(width: 682, height: 450 + 32)) // title bar height
        #expect(window.minSize == window.frame.size)
        #expect(window.maxSize == CGSize(width: 10000, height: 10000))
        // I don't want to run this code even when testing bootstrap, so I've wrapped `unlessTesting` around it
        // #expect(NSApplication.shared.mainMenu != nil)
        #expect(coordinator.methodsCalled == ["createMainModule(window:)"])
        #expect(coordinator.window === window)
        #expect(persistence.methodsCalled == ["registerDefaults()"])
    }

    @Test("doPrefs: calls coordinator showPrefs")
    func doPrefs() {
        let subject = AppDelegate()
        let coordinator = MockRootCoordinator()
        subject.rootCoordinator = coordinator
        subject.doPrefs(NSMenuItem())
        #expect(coordinator.methodsCalled == ["showPrefs()"])
    }

    @Test("showHelp: calls bundle, then workspace")
    func showHelp() {
        let subject = AppDelegate()
        let bundle = MockBundle()
        let workspace = MockWorkspace()
        services.bundle = bundle
        services.workspace = workspace
        bundle.urlToReturn = URL(string: "http://www.example.com")!
        subject.showHelp(NSMenuItem())
        #expect(bundle.methodsCalled == ["url(forResource:withExtension:subdirectory:)"])
        #expect(bundle.name == "help")
        #expect(bundle.ext == "html")
        #expect(bundle.subpath == "help")
        #expect(workspace.methodsCalled == ["open(_:)"])
        #expect(workspace.url == bundle.urlToReturn)
    }
}


