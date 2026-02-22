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
}
