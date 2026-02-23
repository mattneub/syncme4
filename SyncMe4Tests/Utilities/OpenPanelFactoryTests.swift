@testable import SyncMe4
import Testing
import AppKit

struct OpenPanelFactoryTests {
    let subject = OpenPanelFactory()

    @Test("factory makes NSOpenPanel")
    func make() {
        let result = subject.makeOpenPanel()
        #expect(result is NSOpenPanel)
    }
}
