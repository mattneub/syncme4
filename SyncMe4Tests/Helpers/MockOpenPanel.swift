@testable import SyncMe4
import AppKit

final class MockOpenPanel: OpenPanelType {
    var canChooseFiles: Bool = true
    var canChooseDirectories: Bool = false
    var allowsMultipleSelection: Bool = true
    var directoryURL: URL? = URL(string: "http://www.example.com")!
    var url: URL?
    var window: NSWindow?
    var responseToReturn: NSApplication.ModalResponse = .alertFirstButtonReturn
    var methodsCalled = [String]()

    func beginSheetModal(for window: NSWindow) async -> NSApplication.ModalResponse {
        methodsCalled.append(#function)
        self.window = window
        return responseToReturn
    }

}
