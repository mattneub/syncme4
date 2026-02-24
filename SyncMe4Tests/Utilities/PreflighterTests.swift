@testable import SyncMe4
import Testing
import AppKit

struct PreflighterTests: ~Copyable {
    let subject = Preflighter()
    let url1 = URL.temporaryDirectory.appendingPathComponent("left/")
    let url2 = URL.temporaryDirectory.appendingPathComponent("right/")

    init() {
        try! FileManager.default.createDirectory(at: url1, withIntermediateDirectories: true)
        try! FileManager.default.createDirectory(at: url2, withIntermediateDirectories: true)
    }

    deinit {
        try! FileManager.default.removeItem(at: url1)
        try! FileManager.default.removeItem(at: url2)
    }

    @Test("compareFolders: correct for absent right")
    func absentRight() async {
        let copyFrom = url1.appending(component: "test.txt", directoryHint: .notDirectory)
        let copyTo = url2.appending(component: "test.txt", directoryHint: .notDirectory)
        try! "howdy".write(to: copyFrom, atomically: true, encoding: .utf8)
        let result = try! await subject.compareFolders(folder1: url1, folder2: url2)
        #expect(result.count == 1)
        #expect(result[0].copyFrom == copyFrom)
        #expect(result[0].copyTo == copyTo)
        #expect(result[0].why == .absentRight)
    }

    @Test("compareFolders: correct for absent right when item is a folder")
    func absentRightFolder() async {
        let copyFrom = url1.appending(component: "test", directoryHint: .isDirectory)
        let copyTo = url2.appending(component: "test", directoryHint: .isDirectory)
        try! FileManager.default.createDirectory(at: copyFrom, withIntermediateDirectories: true)
        let result = try! await subject.compareFolders(folder1: url1, folder2: url2)
        #expect(result.count == 1)
        #expect(result[0].copyFrom == copyFrom)
        #expect(result[0].copyTo == copyTo)
        #expect(result[0].why == .absentRight)
    }

    @Test("compareFolders: correct for absent left")
    func absentLeft() async {
        let copyFrom = url2.appending(component: "test.txt", directoryHint: .notDirectory)
        let copyTo = url1.appending(component: "test.txt", directoryHint: .notDirectory)
        try! "howdy".write(to: copyFrom, atomically: true, encoding: .utf8)
        let result = try! await subject.compareFolders(folder1: url1, folder2: url2)
        #expect(result.count == 1)
        #expect(result[0].copyFrom == copyFrom)
        #expect(result[0].copyTo == copyTo)
        #expect(result[0].why == .absentLeft)
    }

    @Test("compareFolders: correct for older right")
    func olderRight() async {
        let copyFrom = url1.appending(component: "test.txt", directoryHint: .notDirectory)
        var copyTo = url2.appending(component: "test.txt", directoryHint: .notDirectory)
        try! "howdy".write(to: copyFrom, atomically: true, encoding: .utf8)
        try! "howdy".write(to: copyTo, atomically: true, encoding: .utf8)
        var values: URLResourceValues = .init()
        values.contentModificationDate = Date().addingTimeInterval(-100)
        try! copyTo.setResourceValues(values)
        let result = try! await subject.compareFolders(folder1: url1, folder2: url2)
        #expect(result.count == 1)
        #expect(result[0].copyFrom == copyFrom)
        #expect(result[0].copyTo == copyTo)
        #expect(result[0].why == .olderRight)
    }

    @Test("compareFolders: correct for older left")
    func olderLeft() async {
        let copyFrom = url2.appending(component: "test.txt", directoryHint: .notDirectory)
        var copyTo = url1.appending(component: "test.txt", directoryHint: .notDirectory)
        try! "howdy".write(to: copyFrom, atomically: true, encoding: .utf8)
        try! "howdy".write(to: copyTo, atomically: true, encoding: .utf8)
        var values: URLResourceValues = .init()
        values.contentModificationDate = Date().addingTimeInterval(-100)
        try! copyTo.setResourceValues(values)
        let result = try! await subject.compareFolders(folder1: url1, folder2: url2)
        #expect(result.count == 1)
        #expect(result[0].copyFrom == copyFrom)
        #expect(result[0].copyTo == copyTo)
        #expect(result[0].why == .olderLeft)
    }

    @Test("compareFolders: correct for identical both sides")
    func identical() async {
        var copyFrom = url1.appending(component: "test.txt", directoryHint: .notDirectory)
        var copyTo = url2.appending(component: "test.txt", directoryHint: .notDirectory)
        try! "howdy".write(to: copyFrom, atomically: true, encoding: .utf8)
        try! "howdy".write(to: copyTo, atomically: true, encoding: .utf8)
        let date = Date().addingTimeInterval(-100)
        var values: URLResourceValues = .init()
        values.contentModificationDate = date
        try! copyTo.setResourceValues(values)
        try! copyFrom.setResourceValues(values)
        let result = try! await subject.compareFolders(folder1: url1, folder2: url2)
        #expect(result.count == 0)
    }

    @Test("compareFolders: correct for identical both sides where one is folder and one is not")
    func identicalButFolderVsFile() async {
        // this is a crucial edge case
        let copyFrom = url1.appending(component: "test", directoryHint: .isDirectory)
        let copyTo = url2.appending(component: "test", directoryHint: .notDirectory)
        try! FileManager.default.createDirectory(at: copyFrom, withIntermediateDirectories: true)
        try! "howdy".write(to: copyTo, atomically: true, encoding: .utf8)
        let result = try! await subject.compareFolders(folder1: url1, folder2: url2)
        #expect(result.count == 0)
    }

    @Test("compareFolders: dives into same-named folders")
    func dive() async {
        let url1 = url1.appending(component: "same", directoryHint: .isDirectory)
        let url2 = url2.appending(component: "same", directoryHint: .isDirectory)
        try! FileManager.default.createDirectory(at: url1, withIntermediateDirectories: true)
        try! FileManager.default.createDirectory(at: url2, withIntermediateDirectories: true)
        let copyFrom = url1.appending(component: "test.txt", directoryHint: .notDirectory)
        let copyTo = url2.appending(component: "test.txt", directoryHint: .notDirectory)
        try! "howdy".write(to: copyFrom, atomically: true, encoding: .utf8)
        let result = try! await subject.compareFolders(folder1: self.url1, folder2: self.url2)
        #expect(result.count == 1)
        #expect(result[0].copyFrom == copyFrom)
        #expect(result[0].copyTo == copyTo)
        #expect(result[0].why == .absentRight)
    }
}
