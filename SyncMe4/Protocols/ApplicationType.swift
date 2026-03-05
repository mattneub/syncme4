import AppKit

protocol ApplicationType {
    func terminate(_: Any?)
}

extension NSApplication: ApplicationType {}
