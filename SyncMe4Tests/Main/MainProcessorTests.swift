@testable import SyncMe4
import Testing
import AppKit

struct MainProcessorTests {
    let subject = MainProcessor()
    let presenter = MockReceiverPresenter<Void, MainState>()
    let openPanelOpener = MockOpenPanelOpener()
    let beeper = MockBeeper()
    let preflighter = MockPreflighter()

    init() {
        subject.presenter = presenter
        services.openPanelOpener = openPanelOpener
        services.beeper = beeper
        services.preflighter = preflighter
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

    @Test("receive preflight: calls preflighter compareFolders, sets state results, presents")
    func preflight() async {
        subject.state.leftFolder = URL(string: "http://www.example.com")!
        subject.state.rightFolder = URL(string: "http://www.example2.com")!
        let entry = Entry(copyFrom: URL(string: "http://www.nothing.com")!, copyTo: URL(string: "http://nothing2.com")!, why: .olderLeft)
        preflighter.entries = [entry]
        await subject.receive(.preflight)
        #expect(preflighter.methodsCalled == ["compareFolders(folder1:folder2:)"])
        #expect(preflighter.folder1 == subject.state.leftFolder)
        #expect(preflighter.folder2 == subject.state.rightFolder)
        #expect(subject.state.results == [entry])
        #expect(presenter.statesPresented == [subject.state])
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


}
