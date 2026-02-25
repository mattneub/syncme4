@testable import SyncMe4
import Testing
import Foundation

struct MainStateTests {
    @Test("leftPath is selected entry leftFolderItemPath, urlwrapped, if selection is single")
    func leftPath() {
        var subject = MainState()
        subject.results = [Entry(copyFrom: URL(string: "file:///a/b")!, copyTo: URL(string: "file:///c/d")!, why: .absentRight)]
        subject.selectedResults = [0]
        #expect(subject.leftPath == "/\u{200B}a/\u{200B}b")
        subject.selectedResults = [1, 2]
        #expect(subject.leftPath == nil)
        subject.selectedResults = []
        #expect(subject.leftPath == nil)
    }

    @Test("rightPath is selected entry rightFolderItemPath, urlwrapped, if selection is single")
    func rightPath() {
        var subject = MainState()
        subject.results = [Entry(copyFrom: URL(string: "file:///a/b")!, copyTo: URL(string: "file:///c/d")!, why: .absentRight)]
        subject.selectedResults = [0]
        #expect(subject.rightPath == "/\u{200B}c/\u{200B}d")
        subject.selectedResults = [1, 2]
        #expect(subject.rightPath == nil)
        subject.selectedResults = []
        #expect(subject.rightPath == nil)
    }

    @Test("arrow is selected entry why image, if selection is single")
    func arrow() {
        var subject = MainState()
        subject.results = [Entry(copyFrom: URL(string: "file:///a/b")!, copyTo: URL(string: "file:///c/d")!, why: .absentRight)]
        subject.selectedResults = [0]
        #expect(subject.arrow == "rightarrowgreen")
        subject.selectedResults = [1, 2]
        #expect(subject.arrow == nil)
        subject.selectedResults = []
        #expect(subject.arrow == nil)
    }

}
