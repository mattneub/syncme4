@testable import SyncMe4
import AppKit

final class MockSorter: SorterType {
    var methodsCalled = [String]()
    var entries = [Entry]()
    var sortDescriptors = [NSSortDescriptor]()
    var entriesToReturn = [Entry]()

    func sort(_ entries: [Entry], using sortDescriptors: [NSSortDescriptor]) -> [Entry] {
        methodsCalled.append(#function)
        self.entries = entries
        self.sortDescriptors = sortDescriptors
        return entriesToReturn
    }
}
