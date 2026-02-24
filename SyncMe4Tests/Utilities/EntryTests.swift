@testable import SyncMe4
import Testing
import AppKit

struct EntryTests {
    @Test("leftFolderItemPath: is correct depending on reason")
    func leftFolderItemPath() {
        let url1 = URL(string: "file:///a/b/c")!
        let url2 = URL(string: "file:///d/e/f")!
        var subject = Entry(copyFrom: url1, copyTo: url2, why: .absentRight)
        #expect(subject.leftFolderItemPath == "/a/b/c")
        #expect(subject.rightFolderItemPath == "/d/e/f")
        subject.why = .absentLeft
        #expect(subject.leftFolderItemPath == "/d/e/f")
        #expect(subject.rightFolderItemPath == "/a/b/c")
        subject.why = .olderRight
        #expect(subject.leftFolderItemPath == "/a/b/c")
        #expect(subject.rightFolderItemPath == "/d/e/f")
        subject.why = .olderLeft
        #expect(subject.leftFolderItemPath == "/d/e/f")
        #expect(subject.rightFolderItemPath == "/a/b/c")
    }
}
