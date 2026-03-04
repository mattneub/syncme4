import AppKit

protocol WorkspaceType {
    func open(_ url: URL) -> Bool
}

extension NSWorkspace: WorkspaceType {}
