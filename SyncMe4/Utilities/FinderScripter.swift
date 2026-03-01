import AppKit
import SwiftAutomation
import MacOSGlues

protocol FinderScripterType: Sendable {
    func tickle()
    func reveal(_ url: URL)
    func trash(_ url: URL) throws
    func copy(from source: URL, to destination: URL) throws
}

/// Object that knows how to talk to the Finder using Apple events.
nonisolated
final class FinderScripter: FinderScripterType {
    private let NO_TIME_OUT: TimeInterval = TimeInterval(Int16.max-1) // ~9 hrs; passing -2 said to be buggy

    func tickle() {
        // just enough to trigger the system dialog, if needed, on launch
        let finder = Finder()
        if let name = try? finder.name.get() {
            print(name)
        } else {
            // could terminate at this point, I suppose as we have no purpose without this
        }
    }

    func reveal(_ url: URL) {
        let finder = Finder()
        do {
            try finder.reveal(url)
            try finder.activate()
        } catch {
            do {
                try finder.open(url.deletingLastPathComponent())
                try finder.activate()
            } catch {
                
            }
        }
    }

    func trash(_ url: URL) throws {
        let finder = Finder()
        try finder.delete(url, withTimeout: NO_TIME_OUT)
    }

    func copy(from source: URL, to destination: URL) throws {
        try? trash(destination) // if it fails it fails (might not even exist)
        let destinationContainer = destination.deletingLastPathComponent()
        let finder = Finder()
        try finder.duplicate(source, to: destinationContainer, replacing: true, withTimeout: NO_TIME_OUT)
    }
}
