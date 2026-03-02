@testable import SyncMe4
import Testing
import AppKit

final class MainProcessorTests {
    let subject = MainProcessor()
    let presenter = MockReceiverPresenter<MainEffect, MainState>()
    let openPanelOpener = MockOpenPanelOpener()
    let beeper = MockBeeper()
    let preflighter = MockPreflighter()
    let sorter = MockSorter()
    let finderScripter = MockFinderScripter()

    init() {
        subject.presenter = presenter
        services.openPanelOpener = openPanelOpener
        services.beeper = beeper
        services.preflighter = preflighter
        services.sorter = sorter
        services.finderScripter = finderScripter
    }

    isolated
    deinit {
        subject.progressWatchingTask?.cancel()
    }

    @Test("receive copyAll: clears decks; for each, selects first row, sets current folder, calls copy, cleans state and presents, finally sets current folder nil")
    func copyAll() async {
        let entry1 = Entry(copyFrom: URL(string: "file:///a")!, copyTo: URL(string: "http://nothing4.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "file:///b")!, copyTo: URL(string: "http://nothing5.com")!, why: .olderRight)
        let entry3 = Entry(copyFrom: URL(string: "file:///c")!, copyTo: URL(string: "http://nothing6.com")!, why: .olderRight)
        subject.state.results = [entry1, entry2, entry3]
        subject.state.selectedResults = [0, 2]
        await subject.receive(.copyAll)
        #expect(presenter.thingsReceived == [
            .deselectAllAndScrollToTop,
            .selectFirstRow, .currentFolder("/a"),
            .selectFirstRow, .currentFolder("/b"),
            .selectFirstRow, .currentFolder("/c"),
            .currentFolder(nil)
        ])
        #expect(finderScripter.methodsCalled == ["copy(from:to:)", "copy(from:to:)", "copy(from:to:)"])
        #expect(finderScripter.sources == [URL(string: "file:///a")!, URL(string: "file:///b")!, URL(string: "file:///c")!])
        #expect(finderScripter.destinations == [URL(string: "http://nothing4.com")!, URL(string: "http://nothing5.com")!, URL(string: "http://nothing6.com")!])
        #expect(presenter.statesPresented.count == 5)
        // disabled during, enabled after
        #expect(presenter.statesPresented[0].disabled == true)
        #expect(presenter.statesPresented[1].disabled == true)
        #expect(presenter.statesPresented[2].disabled == true)
        #expect(presenter.statesPresented[3].disabled == true)
        #expect(presenter.statesPresented[4].disabled == false)
        // results successively remove first
        #expect(presenter.statesPresented[1].results == [entry2, entry3])
        #expect(presenter.statesPresented[2].results == [entry3])
        #expect(presenter.statesPresented[3].results == [])
        // selected results always empty
        #expect(presenter.statesPresented[1].selectedResults == [])
        #expect(presenter.statesPresented[2].selectedResults == [])
        #expect(presenter.statesPresented[3].selectedResults == [])
        #expect(presenter.statesPresented[4].selectedResults == [])
    }

    @Test("receive copyAll: if it gets an error, stops, sets current folder nil, enables interface")
    func copyAllError() async {
        let entry1 = Entry(copyFrom: URL(string: "file:///a")!, copyTo: URL(string: "http://nothing4.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "file:///b")!, copyTo: URL(string: "http://nothing5.com")!, why: .olderRight)
        let entry3 = Entry(copyFrom: URL(string: "file:///c")!, copyTo: URL(string: "http://nothing6.com")!, why: .olderRight)
        subject.state.results = [entry1, entry2, entry3]
        subject.state.selectedResults = [0, 2]
        finderScripter.errorToThrow = NSError(domain: "hey", code: 0)
        await subject.receive(.copyAll)
        #expect(presenter.thingsReceived == [
            .deselectAllAndScrollToTop,
            .selectFirstRow, .currentFolder("/a"),
            .currentFolder(nil)
        ])
        #expect(finderScripter.methodsCalled == ["copy(from:to:)"])
        #expect(finderScripter.sources == [URL(string: "file:///a")!])
        #expect(finderScripter.destinations == [URL(string: "http://nothing4.com")!])
        #expect(presenter.statesPresented.count == 2)
        #expect(presenter.statesPresented[0].disabled == true)
        #expect(presenter.statesPresented[1].disabled == false)
    }

    @Test("receive copyAll: is cancellable")
    func copyAllCancellable() async {
        let entry1 = Entry(copyFrom: URL(string: "file:///a")!, copyTo: URL(string: "http://nothing4.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "file:///b")!, copyTo: URL(string: "http://nothing5.com")!, why: .olderRight)
        let entry3 = Entry(copyFrom: URL(string: "file:///c")!, copyTo: URL(string: "http://nothing6.com")!, why: .olderRight)
        subject.state.results = [entry1, entry2, entry3]
        subject.state.selectedResults = [0, 2]
        let task = Task {
            await subject.receive(.copyAll)
        }
        task.cancel()
        try? await Task.sleep(for: .seconds(0.2))
        #expect(presenter.statesPresented.count == 2)
        #expect(presenter.statesPresented[0].disabled == true)
        #expect(presenter.statesPresented[1].disabled == false)
    }

    @Test("receive leftFieldChanged: sets state leftFolder")
    func leftFieldChanged() async {
        let url = URL(string: "https://www.example.com")!
        await subject.receive(.leftFieldChanged(url))
        #expect(subject.state.leftFolder == url)
    }

    @Test("receive leftFieldChoose: calls chooseFolder, if url sets state leftFolder and presents")
    func leftFieldChoose() async {
        let window = NSWindow()
        let url = URL(string: "https://www.example.com")!
        openPanelOpener.urlToReturn = url
        await subject.receive(.leftFieldChoose(window))
        #expect(openPanelOpener.methodsCalled == ["chooseFolder(window:)"])
        #expect(openPanelOpener.window === window)
        #expect(subject.state.leftFolder == url)
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive leftFieldChoose: calls chooseFolder, if nil does nothing")
    func leftFieldChooseNil() async {
        let window = NSWindow()
        let url = URL(string: "https://www.example.com")!
        openPanelOpener.urlToReturn = nil
        subject.state.leftFolder = url
        await subject.receive(.leftFieldChoose(window))
        #expect(openPanelOpener.methodsCalled == ["chooseFolder(window:)"])
        #expect(openPanelOpener.window === window)
        #expect(subject.state.leftFolder == url)
        #expect(presenter.statesPresented.isEmpty)
    }

    @Test("receive preflight: clears the decks, observes preflighter currentFolder, calls preflighter compareFolders, sends effects, sets state results, presents")
    func preflight() async {
        subject.state.leftFolder = URL(string: "http://www.example.com")!
        subject.state.rightFolder = URL(string: "http://www.example2.com")!
        let entry = Entry(copyFrom: URL(string: "http://www.nothing1.com")!, copyTo: URL(string: "http://www.nothing2.com")!, why: .olderLeft)
        preflighter.entries = [entry]
        preflighter.folders = ["Manny", "Moe", "Jack"]
        subject.state.selectedResults = [1, 2, 3]
        subject.state.results = [Entry(copyFrom: URL(string: "file:///dummy")!, copyTo: URL(string: "file:///dummy")!, why: .olderRight)]
        await subject.receive(.preflight)
        #expect(preflighter.methodsCalled == ["prepare()", "compareFolders(folder1:folder2:)"])
        #expect(preflighter.folder1 == subject.state.leftFolder)
        #expect(preflighter.folder2 == subject.state.rightFolder)
        #expect(subject.state.results == [entry])
        #expect(presenter.statesPresented.count == 2)
        #expect(presenter.statesPresented[0].results == [])
        #expect(presenter.statesPresented[0].selectedResults == [])
        #expect(presenter.statesPresented[1] == subject.state)
        #expect(presenter.thingsReceived.count == 4)
        #expect(presenter.thingsReceived == [.currentFolder("Jack"), .currentFolder("Moe"), .currentFolder("Manny"), .currentFolder(nil)])
        #expect(subject.progressWatchingTask?.isCancelled == true)
    }

    @Test("receive preflight: renumbers preflighter results, sets state unsorted")
    func preflightUnsorted() async {
        subject.state.leftFolder = URL(string: "http://www.example.com")!
        subject.state.rightFolder = URL(string: "http://www.example2.com")!
        let entry1 = Entry(copyFrom: URL(string: "http://www.nothing1.com")!, copyTo: URL(string: "http://nothing3.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "http://www.nothing2.com")!, copyTo: URL(string: "http://nothing4.com")!, why: .olderRight)
        preflighter.entries = [entry1, entry2]
        subject.state.unsorted = false
        subject.state.results = [Entry(copyFrom: URL(string: "file:///dummy")!, copyTo: URL(string: "file:///dummy")!, why: .olderRight)]
        await subject.receive(.preflight)
        #expect(subject.state.unsorted == true)
        #expect(subject.state.results.count == 2)
        #expect(subject.state.results[0].id == entry1.id)
        #expect(subject.state.results[0].originalOrder == 0)
        #expect(subject.state.results[1].id == entry2.id)
        #expect(subject.state.results[1].originalOrder == 1)
        #expect(presenter.statesPresented.last == subject.state)
    }

    @Test("receive preflight: if not both folders in state, beeps, does not preflight")
    func preflightNotTwoFolders() async {
        do {
            await subject.receive(.preflight)
            #expect(beeper.methodsCalled == ["beep()"])
            #expect(preflighter.methodsCalled.isEmpty)
        }
        beeper.methodsCalled = []
        subject.state.leftFolder = URL(string: "http://www.example.com")!
        do {
            await subject.receive(.preflight)
            #expect(beeper.methodsCalled == ["beep()"])
            #expect(preflighter.methodsCalled.isEmpty)
        }
        beeper.methodsCalled = []
        subject.state.rightFolder = URL(string: "http://www.example.com")!
        subject.state.leftFolder = nil
        do {
            await subject.receive(.preflight)
            #expect(beeper.methodsCalled == ["beep()"])
            #expect(preflighter.methodsCalled.isEmpty)
        }
    }

    @Test("receive removeFromList: deletes results at given indexes, configures state, presents")
    func removeFromList() async {
        let entry1 = Entry(copyFrom: URL(string: "http://www.nothing1.com")!, copyTo: URL(string: "http://nothing4.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "http://www.nothing2.com")!, copyTo: URL(string: "http://nothing5.com")!, why: .olderRight)
        let entry3 = Entry(copyFrom: URL(string: "http://www.nothing3.com")!, copyTo: URL(string: "http://nothing6.com")!, why: .olderRight)
        subject.state.results = [entry1, entry2, entry3]
        subject.state.selectedResults = [0, 2]
        subject.state.unsorted = false
        await subject.receive(.removeFromList([0, 2]))
        #expect(subject.state.results == [entry2])
        #expect(subject.state.selectedResults == [])
        #expect(subject.state.unsorted == false)
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive reveal: calls finderScripter with copyFrom of entry at given index")
    func reveal() async {
        let entry1 = Entry(copyFrom: URL(string: "http://www.nothing1.com")!, copyTo: URL(string: "http://www.nothing4.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "http://www.nothing2.com")!, copyTo: URL(string: "http://www.nothing5.com")!, why: .olderRight)
        let entry3 = Entry(copyFrom: URL(string: "http://www.nothing3.com")!, copyTo: URL(string: "http://www.nothing6.com")!, why: .olderRight)
        subject.state.results = [entry1, entry2, entry3]
        await subject.receive(.reveal(1))
        #expect(finderScripter.methodsCalled == ["reveal(_:)"])
        #expect(finderScripter.urls[0] == entry2.copyFrom)
    }

    @Test("receive revealTarget: calls finderScripter with copyTo of entry at given index")
    func revealTarget() async {
        let entry1 = Entry(copyFrom: URL(string: "http://www.nothing1.com")!, copyTo: URL(string: "http://www.nothing4.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "http://www.nothing2.com")!, copyTo: URL(string: "http://www.nothing5.com")!, why: .olderRight)
        let entry3 = Entry(copyFrom: URL(string: "http://www.nothing3.com")!, copyTo: URL(string: "http://www.nothing6.com")!, why: .olderRight)
        subject.state.results = [entry1, entry2, entry3]
        await subject.receive(.revealTarget(1))
        #expect(finderScripter.methodsCalled == ["reveal(_:)"])
        #expect(finderScripter.urls[0] == entry2.copyTo)
    }

    @Test("reverseDirection: if entry at index has reason .absent..., beeps and stops")
    func reverseDirectionAbsent() async {
        let entry1 = Entry(copyFrom: URL(string: "http://www.nothing1.com")!, copyTo: URL(string: "http://www.nothing4.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "http://www.nothing2.com")!, copyTo: URL(string: "http://www.nothing5.com")!, why: .absentLeft)
        let entry3 = Entry(copyFrom: URL(string: "http://www.nothing3.com")!, copyTo: URL(string: "http://www.nothing6.com")!, why: .absentRight)
        subject.state.results = [entry1, entry2, entry3]
        await subject.receive(.reverseDirection(1))
        #expect(beeper.methodsCalled == ["beep()"])
        #expect(presenter.statesPresented.isEmpty)
        beeper.methodsCalled = []
        await subject.receive(.reverseDirection(2))
        #expect(beeper.methodsCalled == ["beep()"])
        #expect(presenter.statesPresented.isEmpty)
    }

    @Test("reverseDirection: if entry at index has reason .older..., swaps direction and copyto/from, presents")
    func reverseDirectionOlder() async {
        let entry1 = Entry(copyFrom: URL(string: "http://www.nothing1.com")!, copyTo: URL(string: "http://www.nothing4.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "http://www.nothing2.com")!, copyTo: URL(string: "http://www.nothing5.com")!, why: .olderRight)
        let entry3 = Entry(copyFrom: URL(string: "http://www.nothing3.com")!, copyTo: URL(string: "http://www.nothing6.com")!, why: .absentRight)
        subject.state.results = [entry1, entry2, entry3]
        await subject.receive(.reverseDirection(0))
        #expect(subject.state.results[0].id == entry1.id)
        #expect(subject.state.results[0].copyFrom == entry1.copyTo)
        #expect(subject.state.results[0].copyTo == entry1.copyFrom)
        #expect(subject.state.results[0].why == .olderRight)
        #expect(subject.state.results[1] == entry2)
        #expect(subject.state.results[2] == entry3)
    }

    @Test("reverseDirection: if entry at index has reason .older..., swaps direction and copyto/from, presents")
    func reverseDirectionOlder2() async {
        let entry1 = Entry(copyFrom: URL(string: "http://www.nothing1.com")!, copyTo: URL(string: "http://www.nothing4.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "http://www.nothing2.com")!, copyTo: URL(string: "http://www.nothing5.com")!, why: .olderRight)
        let entry3 = Entry(copyFrom: URL(string: "http://www.nothing3.com")!, copyTo: URL(string: "http://www.nothing6.com")!, why: .absentRight)
        subject.state.results = [entry1, entry2, entry3]
        await subject.receive(.reverseDirection(1))
        #expect(subject.state.results[0] == entry1)
        #expect(subject.state.results[1].id == entry2.id)
        #expect(subject.state.results[1].copyFrom == entry2.copyTo)
        #expect(subject.state.results[1].copyTo == entry2.copyFrom)
        #expect(subject.state.results[1].why == .olderLeft)
        #expect(subject.state.results[2] == entry3)
    }

    @Test("receive rightFieldChanged: sets state rightFolder")
    func rightFieldChanged() async {
        let url = URL(string: "https://www.example.com")!
        await subject.receive(.rightFieldChanged(url))
        #expect(subject.state.rightFolder == url)
    }

    @Test("receive rightFieldChoose: calls chooseFolder, if url sets state rightFolder and presents")
    func rightFieldChoose() async {
        let window = NSWindow()
        let url = URL(string: "https://www.example.com")!
        openPanelOpener.urlToReturn = url
        await subject.receive(.rightFieldChoose(window))
        #expect(openPanelOpener.methodsCalled == ["chooseFolder(window:)"])
        #expect(openPanelOpener.window === window)
        #expect(subject.state.rightFolder == url)
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive rightFieldChoose: calls chooseFolder, if nil does nothing")
    func rightFieldChooseNil() async {
        let window = NSWindow()
        let url = URL(string: "https://www.example.com")!
        openPanelOpener.urlToReturn = nil
        subject.state.rightFolder = url
        await subject.receive(.rightFieldChoose(window))
        #expect(openPanelOpener.methodsCalled == ["chooseFolder(window:)"])
        #expect(openPanelOpener.window === window)
        #expect(subject.state.rightFolder == url)
        #expect(presenter.statesPresented.isEmpty)
    }

    @Test("receive selectedRows: sets state selectedResults, presents")
    func selectedRows() async {
        await subject.receive(.selectedRows([1, 3, 5]))
        #expect(subject.state.selectedResults == [1, 3, 5])
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive tickle: calls finder scripter tickle")
    func tickle() async {
        await subject.receive(.tickle)
        #expect(finderScripter.methodsCalled == ["tickle()"])
    }

    @Test("receive trash: calls finder scripter trash with copyFrom and presenter remove for each listed entry, reconciles state and presents")
    func trash() async {
        let entry1 = Entry(copyFrom: URL(string: "http://www.nothing1.com")!, copyTo: URL(string: "http://www.nothing4.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "http://www.nothing2.com")!, copyTo: URL(string: "http://www.nothing5.com")!, why: .olderRight)
        let entry3 = Entry(copyFrom: URL(string: "http://www.nothing3.com")!, copyTo: URL(string: "http://www.nothing6.com")!, why: .absentRight)
        subject.state.results = [entry1, entry2, entry3]
        subject.state.selectedResults = [1, 2]
        await subject.receive(.trash([0, 2]))
        #expect(finderScripter.methodsCalled == ["trash(_:)", "trash(_:)"])
        #expect(finderScripter.urls == [URL(string: "http://www.nothing1.com")!, URL(string: "http://www.nothing3.com")!])
        #expect(presenter.thingsReceived == [.scrollToRow(0), .scrollToRow(1)]) // because with 0 gone, 2 becomes 1
        #expect(subject.state.results == [entry2])
        #expect(subject.state.selectedResults == [])
        #expect(presenter.statesPresented.count == 4)
        // disable at start, enable at end
        #expect(presenter.statesPresented[0].disabled == true)
        #expect(presenter.statesPresented[1].disabled == true)
        #expect(presenter.statesPresented[2].disabled == true)
        #expect(presenter.statesPresented[3].disabled == false)
        // eliminate selected indexes
        #expect(presenter.statesPresented[1].results == [entry2, entry3])
        #expect(presenter.statesPresented[1].selectedResults == [1]) // ditto
        #expect(presenter.statesPresented[2].results == [entry2])
        #expect(presenter.statesPresented[2].selectedResults == [])
    }

    @Test("receive trash: if an error is returned, enables and stops")
    func trashWithError() async {
        let entry1 = Entry(copyFrom: URL(string: "http://www.nothing1.com")!, copyTo: URL(string: "http://www.nothing4.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "http://www.nothing2.com")!, copyTo: URL(string: "http://www.nothing5.com")!, why: .olderRight)
        let entry3 = Entry(copyFrom: URL(string: "http://www.nothing3.com")!, copyTo: URL(string: "http://www.nothing6.com")!, why: .absentRight)
        subject.state.results = [entry1, entry2, entry3]
        subject.state.selectedResults = [1, 2]
        finderScripter.errorToThrow = NSError(domain: "domain", code: 0)
        await subject.receive(.trash([0, 2]))
        #expect(finderScripter.methodsCalled == ["trash(_:)"])
        #expect(finderScripter.urls == [URL(string: "http://www.nothing1.com")!])
        #expect(presenter.thingsReceived == [.scrollToRow(0)])
        #expect(subject.state.results == [entry1, entry2, entry3])
        #expect(subject.state.selectedResults == [1, 2])
        #expect(presenter.statesPresented.count == 2)
        #expect(presenter.statesPresented[0].disabled == true)
        #expect(presenter.statesPresented[1].disabled == false)
    }

    @Test("receive trashTarget: calls finder scripter trash with copyTo and presenter scroll, reconciles state and presents, for each listed entry")
    func trashTarget() async {
        let entry1 = Entry(copyFrom: URL(string: "http://www.nothing1.com")!, copyTo: URL(string: "http://www.nothing4.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "http://www.nothing2.com")!, copyTo: URL(string: "http://www.nothing5.com")!, why: .olderRight)
        let entry3 = Entry(copyFrom: URL(string: "http://www.nothing3.com")!, copyTo: URL(string: "http://www.nothing6.com")!, why: .olderLeft)
        subject.state.results = [entry1, entry2, entry3]
        subject.state.selectedResults = [1, 2]
        await subject.receive(.trashTarget([0, 2]))
        #expect(finderScripter.methodsCalled == ["trash(_:)", "trash(_:)"])
        #expect(finderScripter.urls == [URL(string: "http://www.nothing4.com")!, URL(string: "http://www.nothing6.com")!])
        #expect(presenter.thingsReceived == [.scrollToRow(0), .scrollToRow(1)]) // because with 0 gone, 2 becomes 1
        #expect(subject.state.results == [entry2])
        #expect(subject.state.selectedResults == [])
        #expect(presenter.statesPresented.count == 4)
        // disable at start, enable at end
        #expect(presenter.statesPresented[0].disabled == true)
        #expect(presenter.statesPresented[1].disabled == true)
        #expect(presenter.statesPresented[2].disabled == true)
        #expect(presenter.statesPresented[3].disabled == false)
        // eliminate selected indexes
        #expect(presenter.statesPresented[1].results == [entry2, entry3])
        #expect(presenter.statesPresented[1].selectedResults == [1]) // ditto
        #expect(presenter.statesPresented[2].results == [entry2])
        #expect(presenter.statesPresented[2].selectedResults == [])
    }

    @Test("receive trashTarget: if an error is returned, enables and stops")
    func trashTargetWithError() async {
        let entry1 = Entry(copyFrom: URL(string: "http://www.nothing1.com")!, copyTo: URL(string: "http://www.nothing4.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "http://www.nothing2.com")!, copyTo: URL(string: "http://www.nothing5.com")!, why: .olderRight)
        let entry3 = Entry(copyFrom: URL(string: "http://www.nothing3.com")!, copyTo: URL(string: "http://www.nothing6.com")!, why: .olderLeft)
        subject.state.results = [entry1, entry2, entry3]
        subject.state.selectedResults = [1, 2]
        finderScripter.errorToThrow = NSError(domain: "domain", code: 0)
        await subject.receive(.trashTarget([0, 2]))
        #expect(finderScripter.methodsCalled == ["trash(_:)"])
        #expect(finderScripter.urls == [URL(string: "http://www.nothing4.com")!])
        #expect(presenter.thingsReceived == [.scrollToRow(0)])
        #expect(subject.state.results == [entry1, entry2, entry3])
        #expect(subject.state.selectedResults == [1, 2])
        #expect(presenter.statesPresented.count == 2)
        #expect(presenter.statesPresented[0].disabled == true)
        #expect(presenter.statesPresented[1].disabled == false)
    }

    @Test("receive trashTarget: if any chosen entry has no existing destination, beeps and stops")
    func trashTargetNoDestination() async {
        let entry1 = Entry(copyFrom: URL(string: "http://www.nothing1.com")!, copyTo: URL(string: "http://www.nothing4.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "http://www.nothing2.com")!, copyTo: URL(string: "http://www.nothing5.com")!, why: .olderRight)
        let entry3 = Entry(copyFrom: URL(string: "http://www.nothing3.com")!, copyTo: URL(string: "http://www.nothing6.com")!, why: .absentLeft) // *
        subject.state.results = [entry1, entry2, entry3]
        subject.state.selectedResults = [1, 2]
        await subject.receive(.trashTarget([0, 2]))
        #expect(beeper.methodsCalled == ["beep()"])
        #expect(finderScripter.methodsCalled.isEmpty)
        #expect(presenter.thingsReceived.isEmpty) // because 2 becomes 1 after 0 is removed
        #expect(subject.state.results == [entry1, entry2, entry3])
        #expect(subject.state.selectedResults == [1, 2])
        #expect(presenter.statesPresented.isEmpty)
    }

    @Test("receive unsort: calls sorter with empty sort descriptors, configures state, presents")
    func unsort() async {
        let entry1 = Entry(copyFrom: URL(string: "http://www.nothing1.com")!, copyTo: URL(string: "http://www.nothing3.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "http://www.nothing2.com")!, copyTo: URL(string: "http://www.nothing4.com")!, why: .olderRight)
        sorter.entriesToReturn = [entry1, entry2]
        let dummy = Entry(copyFrom: URL(string: "file:///dummy")!, copyTo: URL(string: "file:///dummy")!, why: .olderRight)
        subject.state.results = [dummy]
        subject.state.selectedResults = [1, 2, 3]
        subject.state.unsorted = false
        await subject.receive(.unsort)
        #expect(sorter.methodsCalled == ["sort(_:using:)"])
        #expect(sorter.entries == [dummy])
        #expect(sorter.sortDescriptors == [])
        #expect(subject.state.results == [entry1, entry2])
        #expect(subject.state.unsorted == true)
        #expect(subject.state.selectedResults == [])
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive updateResults: calls sorter, configures state, presents")
    func updateResults() async {
        let entry1 = Entry(copyFrom: URL(string: "http://www.nothing1.com")!, copyTo: URL(string: "http://www.nothing3.com")!, why: .olderLeft)
        let entry2 = Entry(copyFrom: URL(string: "http://www.nothing2.com")!, copyTo: URL(string: "http://www.nothing4.com")!, why: .olderRight)
        sorter.entriesToReturn = [entry1, entry2]
        let sortDescriptor = NSSortDescriptor(key: "howdy", ascending: false)
        let dummy = Entry(copyFrom: URL(string: "file:///dummy")!, copyTo: URL(string: "file:///dummy")!, why: .olderRight)
        subject.state.results = [dummy]
        subject.state.selectedResults = [1, 2, 3]
        await subject.receive(.updateResults([sortDescriptor]))
        #expect(sorter.methodsCalled == ["sort(_:using:)"])
        #expect(sorter.entries == [dummy])
        #expect(sorter.sortDescriptors == [sortDescriptor])
        #expect(subject.state.results == [entry1, entry2])
        #expect(subject.state.unsorted == false)
        #expect(subject.state.selectedResults == [])
        #expect(presenter.statesPresented == [subject.state])
    }
}
