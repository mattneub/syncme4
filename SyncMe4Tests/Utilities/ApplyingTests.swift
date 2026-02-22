@testable import SyncMe4
import Testing
import AppKit

private struct ApplyingTests {
    @Test("applying works as expected")
    func applying() {
        let view = NSView().applying {
            $0.isHidden = true
            $0.frame = NSRect(x: 10, y: 10, width: 30, height: 30)
        }
        #expect(view.isHidden == true)
        #expect(view.frame == NSRect(x: 10, y: 10, width: 30, height: 30))
    }
}
