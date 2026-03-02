@testable import SyncMe4
import Testing
import AppKit
import WaitWhile

struct PreflighterTests: ~Copyable {
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

    @Test("prepare: sets currentFolder to empty string")
    func prepare() {
        let subject = Preflighter()
        #expect(subject.currentFolder == nil)
        subject.prepare()
        #expect(subject.currentFolder == "")
    }

    @Test("compareFolders: correct for absent right")
    func absentRight() async {
        let subject = Preflighter()
        let copyFrom = url1.appending(component: "test.txt", directoryHint: .notDirectory)
        let copyTo = url2.appending(component: "test.txt", directoryHint: .notDirectory)
        try! "howdy".write(to: copyFrom, atomically: true, encoding: .utf8)
        let result = try! await subject.compareFolders(folder1: url1, folder2: url2, stopList: [])
        #expect(result.count == 1)
        #expect(result[0].copyFrom == copyFrom)
        #expect(result[0].copyTo == copyTo)
        #expect(result[0].why == .absentRight)
    }

    @Test("compareFolders: correct for absent right when item is a folder")
    func absentRightFolder() async {
        let subject = Preflighter()
        let copyFrom = url1.appending(component: "test", directoryHint: .isDirectory)
        let copyTo = url2.appending(component: "test", directoryHint: .isDirectory)
        try! FileManager.default.createDirectory(at: copyFrom, withIntermediateDirectories: true)
        let result = try! await subject.compareFolders(folder1: url1, folder2: url2, stopList: [])
        #expect(result.count == 1)
        #expect(result[0].copyFrom == copyFrom)
        #expect(result[0].copyTo == copyTo)
        #expect(result[0].why == .absentRight)
    }

    @Test("compareFolders: correct for absent left")
    func absentLeft() async {
        let subject = Preflighter()
        let copyFrom = url2.appending(component: "test.txt", directoryHint: .notDirectory)
        let copyTo = url1.appending(component: "test.txt", directoryHint: .notDirectory)
        try! "howdy".write(to: copyFrom, atomically: true, encoding: .utf8)
        let result = try! await subject.compareFolders(folder1: url1, folder2: url2, stopList: [])
        #expect(result.count == 1)
        #expect(result[0].copyFrom == copyFrom)
        #expect(result[0].copyTo == copyTo)
        #expect(result[0].why == .absentLeft)
    }

    @Test("compareFolders: correctly omits entries that are in stop list")
    func absentLeftStopList() async {
        let subject = Preflighter()
        let copyFrom = url2.appending(component: "test.txt", directoryHint: .notDirectory)
        try! "howdy".write(to: copyFrom, atomically: true, encoding: .utf8)
        let result = try! await subject.compareFolders(folder1: url1, folder2: url2, stopList: ["test.txt", "ho"])
        #expect(result.count == 0)
    }

    @Test("compareFolders: correct for older right")
    func olderRight() async {
        let subject = Preflighter()
        let copyFrom = url1.appending(component: "test.txt", directoryHint: .notDirectory)
        var copyTo = url2.appending(component: "test.txt", directoryHint: .notDirectory)
        try! "howdy".write(to: copyFrom, atomically: true, encoding: .utf8)
        try! "howdy".write(to: copyTo, atomically: true, encoding: .utf8)
        var values: URLResourceValues = .init()
        values.contentModificationDate = Date().addingTimeInterval(-100)
        try! copyTo.setResourceValues(values)
        let result = try! await subject.compareFolders(folder1: url1, folder2: url2, stopList: [])
        #expect(result.count == 1)
        #expect(result[0].copyFrom == copyFrom)
        #expect(result[0].copyTo == copyTo)
        #expect(result[0].why == .olderRight)
    }

    @Test("compareFolders: correct for older left")
    func olderLeft() async {
        let subject = Preflighter()
        let copyFrom = url2.appending(component: "test.txt", directoryHint: .notDirectory)
        var copyTo = url1.appending(component: "test.txt", directoryHint: .notDirectory)
        try! "howdy".write(to: copyFrom, atomically: true, encoding: .utf8)
        try! "howdy".write(to: copyTo, atomically: true, encoding: .utf8)
        var values: URLResourceValues = .init()
        values.contentModificationDate = Date().addingTimeInterval(-100)
        try! copyTo.setResourceValues(values)
        let result = try! await subject.compareFolders(folder1: url1, folder2: url2, stopList: [])
        #expect(result.count == 1)
        #expect(result[0].copyFrom == copyFrom)
        #expect(result[0].copyTo == copyTo)
        #expect(result[0].why == .olderLeft)
    }

    @Test("compareFolders: correct for identical both sides")
    func identical() async {
        let subject = Preflighter()
        var copyFrom = url1.appending(component: "test.txt", directoryHint: .notDirectory)
        var copyTo = url2.appending(component: "test.txt", directoryHint: .notDirectory)
        try! "howdy".write(to: copyFrom, atomically: true, encoding: .utf8)
        try! "howdy".write(to: copyTo, atomically: true, encoding: .utf8)
        let date = Date().addingTimeInterval(-100)
        var values: URLResourceValues = .init()
        values.contentModificationDate = date
        try! copyTo.setResourceValues(values)
        try! copyFrom.setResourceValues(values)
        let result = try! await subject.compareFolders(folder1: url1, folder2: url2, stopList: [])
        #expect(result.count == 0)
    }

    @Test("compareFolders: correct for identical both sides where one is folder and one is not")
    func identicalButFolderVsFile() async {
        let subject = Preflighter()
        var copyFrom = url1.appending(component: "test", directoryHint: .isDirectory)
        let copyTo = url2.appending(component: "test", directoryHint: .notDirectory)
        try! FileManager.default.createDirectory(at: copyFrom, withIntermediateDirectories: true)
        try! "howdy".write(to: copyTo, atomically: true, encoding: .utf8)
        let date = Date().addingTimeInterval(-100)
        var values: URLResourceValues = .init()
        values.contentModificationDate = date
        try! copyFrom.setResourceValues(values)
        let result = try! await subject.compareFolders(folder1: url1, folder2: url2, stopList: [])
        #expect(result.count == 0)
    }

    @Test("compareFolders: correct for identical both sides where one is folder and one is not, other way round")
    func identicalButFolderVsFileOtherWayRound() async {
        let subject = Preflighter()
        var copyFrom = url1.appending(component: "test", directoryHint: .notDirectory)
        let copyTo = url2.appending(component: "test", directoryHint: .isDirectory)
        try! FileManager.default.createDirectory(at: copyTo, withIntermediateDirectories: true)
        try! "howdy".write(to: copyFrom, atomically: true, encoding: .utf8)
        let date = Date().addingTimeInterval(-100)
        var values: URLResourceValues = .init()
        values.contentModificationDate = date
        try! copyFrom.setResourceValues(values)
        let result = try! await subject.compareFolders(folder1: url1, folder2: url2, stopList: [])
        #expect(result.count == 0)
    }

    @Test("compareFolders: dives into same-named folders, sets currentFolder as it goes")
    func dive() async {
        // I have no idea why this test fails the first time but then succeeds, it's weird
        let subject = Preflighter()
        subject.currentFolder = ""
        try? await Task.sleep(for: .seconds(0.1))
        var currentFolders = [String?]()
        let task = Task {
            let observations = Observations { subject.currentFolder }
            for await currentFolder in observations {
                currentFolders.append(currentFolder)
            }
        }
        try? await Task.sleep(for: .seconds(0.1))
        let url1 = url1.appending(component: "same", directoryHint: .isDirectory)
        let url2 = url2.appending(component: "same", directoryHint: .isDirectory)
        try! FileManager.default.createDirectory(at: url1, withIntermediateDirectories: true)
        try! FileManager.default.createDirectory(at: url2, withIntermediateDirectories: true)
        let copyFrom = url1.appending(component: "test.txt", directoryHint: .notDirectory)
        let copyTo = url2.appending(component: "test.txt", directoryHint: .notDirectory)
        try! "howdy".write(to: copyFrom, atomically: true, encoding: .utf8)
        let result = try! await subject.compareFolders(folder1: self.url1, folder2: self.url2, stopList: [])
        #expect(result.count == 1)
        #expect(result[0].copyFrom == copyFrom)
        #expect(result[0].copyTo == copyTo)
        #expect(result[0].why == .absentRight)
        try? await Task.sleep(for: .seconds(1))
        let expectedFolders = [
            self.url1,
            url1,
            self.url2,
            url2
        ].map { $0.path(percentEncoded: false) }
        let expected: [String?] = [""] + expectedFolders + [nil]
        #expect(currentFolders == expected)
        task.cancel()
    }

    @Test("compareFolders: correctly omits entries from stop list when diving")
    func diveStopList() async {
        // I have no idea why this test fails the first time but then succeeds, it's weird
        let subject = Preflighter()
        subject.currentFolder = ""
        let url1 = url1.appending(component: "same", directoryHint: .isDirectory)
        let url2 = url2.appending(component: "same", directoryHint: .isDirectory)
        try! FileManager.default.createDirectory(at: url1, withIntermediateDirectories: true)
        try! FileManager.default.createDirectory(at: url2, withIntermediateDirectories: true)
        let copyFrom = url1.appending(component: "test.txt", directoryHint: .notDirectory)
        try! "howdy".write(to: copyFrom, atomically: true, encoding: .utf8)
        let result = try! await subject.compareFolders(folder1: self.url1, folder2: self.url2, stopList: ["test.txt", "howdy"])
        #expect(result.count == 0)
    }


    @Test("compareFolders: is cancellable")
    func diveCancel() async {
        let subject = Preflighter()
        subject.currentFolder = ""
        try? await Task.sleep(for: .seconds(0.1))
        var currentFolders = [String?]()
        let task = Task {
            let observations = Observations { subject.currentFolder }
            for await currentFolder in observations {
                currentFolders.append(currentFolder)
            }
        }
        try? await Task.sleep(for: .seconds(0.1))
        let url1 = url1.appending(component: "same", directoryHint: .isDirectory)
        let url2 = url2.appending(component: "same", directoryHint: .isDirectory)
        try! FileManager.default.createDirectory(at: url1, withIntermediateDirectories: true)
        try! FileManager.default.createDirectory(at: url2, withIntermediateDirectories: true)
        let copyFrom = url1.appending(component: "test.txt", directoryHint: .notDirectory)
        try! "howdy".write(to: copyFrom, atomically: true, encoding: .utf8)
        let selfurl1 = self.url1
        let selfurl2 = self.url2
        let task2 = Task {
            _ = try? await subject.compareFolders(folder1: selfurl1, folder2: selfurl2, stopList: [])
        }
        task2.cancel()
        try? await Task.sleep(for: .seconds(0.2))
        try? await Task.sleep(for: .seconds(1))
        let expectedFolders = [
            self.url1, // and that's as far as we get
        ].map { $0.path(percentEncoded: false) }
        let expected: [String?] = [""] + expectedFolders
        #expect(currentFolders == expected)
        task.cancel()
    }
}
