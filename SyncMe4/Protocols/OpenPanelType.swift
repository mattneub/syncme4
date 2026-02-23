import AppKit

protocol OpenPanelType: AnyObject {
    var canChooseFiles: Bool { get set }
    var canChooseDirectories: Bool { get set }
    var allowsMultipleSelection: Bool { get set }
    var directoryURL: URL? { get set }
    var url: URL? { get }
    func beginSheetModal(for: NSWindow) async -> NSApplication.ModalResponse
}

extension NSOpenPanel: OpenPanelType {}
