@testable import SyncMe4
import AppKit

final class MockOpenPanelOpener: OpenPanelOpenerType {
    var methodsCalled = [String]()
    var window: NSWindow?
    var urlToReturn: URL?

    func chooseFolder(window: NSWindow) async -> URL? {
        methodsCalled.append(#function)
        self.window = window
        return urlToReturn
    }
}
