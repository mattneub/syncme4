@testable import SyncMe4
import AppKit

@discardableResult
func makeWindow(viewController: NSViewController) -> NSWindow {
    let window = NSWindow(
        contentRect: NSRect(x: -10000, y: -10000, width: 480, height: 272),
        styleMask: [.miniaturizable, .closable, .resizable, .titled],
        backing: .buffered,
        defer: false
    )
    window.contentViewController = viewController
    window.makeKeyAndOrderFront(nil)
    window.isReleasedWhenClosed = false
    return window
}

@discardableResult
func makeWindow(view: NSView) -> NSWindow {
    let window = NSWindow(
        contentRect: NSRect(x: -10000, y: -10000, width: 480, height: 272),
        styleMask: [.miniaturizable, .closable, .resizable, .titled],
        backing: .buffered,
        defer: false
    )
    window.contentView = view
    window.makeKeyAndOrderFront(nil)
    window.isReleasedWhenClosed = false
    return window
}

nonisolated
func closeWindows() {
    Task { @MainActor in
        for window in NSApplication.shared.windows {
            window.close()
        }
    }
}
