@testable import SyncMe4
import Testing
import AppKit

struct OpenPanelOpenerTests {
    let subject = OpenPanelOpener()
    let panel = MockOpenPanel()
    let window = NSWindow()

    init() {
        struct MockFactory: OpenPanelFactoryType {
            var panel: MockOpenPanel!
            func makeOpenPanel() -> any OpenPanelType {
                return panel
            }
        }
        var factory = MockFactory()
        factory.panel = panel
        services.openPanelFactory = factory
    }

    @Test("chooseFolder: sets panel properties, calls beginSheetModal, if cancel, returns nil")
    func chooseFolderCancel() async {
        panel.responseToReturn = .cancel
        let result = await subject.chooseFolder(window: window)
        #expect(panel.canChooseFiles == false)
        #expect(panel.canChooseDirectories == true)
        #expect(panel.allowsMultipleSelection == false)
        #expect(panel.directoryURL == nil)
        #expect(panel.methodsCalled == ["beginSheetModal(for:)"])
        #expect(panel.window === window)
        #expect(result == nil)
    }

    @Test("chooseFolder: sets panel properties, calls beginSheetModal, if ok, returns url")
    func chooseFolderOK() async {
        panel.responseToReturn = .OK
        let result = await subject.chooseFolder(window: window)
        #expect(panel.canChooseFiles == false)
        #expect(panel.canChooseDirectories == true)
        #expect(panel.allowsMultipleSelection == false)
        #expect(panel.directoryURL == nil)
        #expect(panel.methodsCalled == ["beginSheetModal(for:)"])
        #expect(panel.window === window)
        #expect(result == panel.url)
    }
}
