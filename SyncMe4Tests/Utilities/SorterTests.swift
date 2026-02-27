@testable import SyncMe4
import Testing
import AppKit

struct SorterTests {
    let subject = Sorter()

    @Test("sort: if descriptors is empty, sorts by original order")
    func sortEmpty() {
        var entry1 = Entry(copyFrom: URL(string: "file:///manny")!, copyTo: URL(string: "file:///dummy")!, why: .olderLeft)
        entry1.originalOrder = 1
        var entry2 = Entry(copyFrom: URL(string: "file:///moe")!, copyTo: URL(string: "file:///dummy")!, why: .olderLeft)
        entry2.originalOrder = 0
        let result = subject.sort([entry1, entry2], using: [])
        #expect(result == [entry2, entry1])
    }

    @Test("sort: if first descriptor is path, sorts by left path, ascending or descending")
    func sortPath() {
        // if reason says Right, path in question comes from copyFrom
        let entry1 = Entry(copyFrom: URL(string: "file:///manny")!, copyTo: URL(string: "file:///dummy")!, why: .olderRight)
        let entry2 = Entry(copyFrom: URL(string: "file:///jack")!, copyTo: URL(string: "file:///dummy")!, why: .olderRight)
        let result = subject.sort([entry1, entry2], using: [NSSortDescriptor(key: "path", ascending: true)])
        #expect(result == [entry2, entry1])
        let result2 = subject.sort([entry2, entry1], using: [NSSortDescriptor(key: "path", ascending: false)])
        #expect(result2 == [entry1, entry2])
    }

    @Test("sort: if first descriptor is path, sorts by left path, ascending or descending")
    func sortPath2() {
        // if reason says Left, path in question comes from copyTo
        let entry1 = Entry(copyFrom: URL(string: "file:///dummy")!, copyTo: URL(string: "file:///manny")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "file:///dummy")!, copyTo: URL(string: "file:///jack")!, why: .olderLeft)
        let result = subject.sort([entry1, entry2], using: [NSSortDescriptor(key: "path", ascending: true)])
        #expect(result == [entry2, entry1])
        let result2 = subject.sort([entry2, entry1], using: [NSSortDescriptor(key: "path", ascending: false)])
        #expect(result2 == [entry1, entry2])
    }

    @Test("sort: if first descriptor is why, sorts by reason raw value, ascending or descending")
    func sortWhy() {
        let entry1 = Entry(copyFrom: URL(string: "file:///manny")!, copyTo: URL(string: "file:///dummy")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "file:///jack")!, copyTo: URL(string: "file:///dummy")!, why: .olderRight)
        let result = subject.sort([entry1, entry2], using: [NSSortDescriptor(key: "why", ascending: true)])
        #expect(result == [entry2, entry1])
        let result2 = subject.sort([entry2, entry1], using: [NSSortDescriptor(key: "why", ascending: false)])
        #expect(result2 == [entry1, entry2])
    }
}
