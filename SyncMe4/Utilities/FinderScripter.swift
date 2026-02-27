import AppKit
import SwiftAutomation
import MacOSGlues

protocol FinderScripterType {
    func tickle()
}

/// Object that knows how to talk to the Finder using Apple events.
final class FinderScripter: FinderScripterType {
    func tickle() {
        // just enough to trigger the system dialog, if needed, on launch
        let finder = Finder()
        if let name = try? finder.name.get() {
            print(name)
        } else {
            // could terminate at this point, I suppose as we have no purpose without this
        }
    }
}
