import AppKit

protocol OpenPanelOpenerType {
    func chooseFolder(window: NSWindow) async -> URL?
}

final class OpenPanelOpener: OpenPanelOpenerType {
    func chooseFolder(window: NSWindow) async -> URL? {
        let panel = services.openPanelFactory.makeOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = nil
        let result = await panel.beginSheetModal(for: window)
        if result == .cancel {
            return nil
        }
        return panel.url
    }
}

