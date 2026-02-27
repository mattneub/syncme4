@testable import SyncMe4
import Testing
import AppKit
import WaitWhile

struct MainViewControllerTests {
    let subject = MainViewController()
    let processor = MockProcessor<MainAction, MainState, Void>()
    let datasource = MockMainDatasource()

    init() {
        subject.processor = processor
        subject.datasource = datasource
    }

    @Test("nibName: is correct")
    func nibName() {
        #expect(subject.nibName == "Main")
    }

    @Test("datasource is MainDatasource")
    func datasourceInitializer() {
        let subject = MainViewController()
        subject.loadViewIfNeeded()
        _ = subject.datasource
        #expect(subject.datasource is MainDatasource)
    }

    @Test("progress interface is hidden, text fields are emptied")
    func progressInterface() {
        subject.loadViewIfNeeded()
        #expect(subject.nowProcessing.isHidden)
        #expect(subject.currentFolder.isHidden)
        #expect(subject.cancelButton.isHidden)
        #expect(subject.leftSelected.stringValue == "")
        #expect(subject.rightSelected.stringValue == "")
    }

    @Test("viewDidLoad: configures table view")
    func viewDidLoad() {
        subject.loadViewIfNeeded()
        #expect(subject.tableView.allowsMultipleSelection == true)
    }

    @Test("present: sets leftField and rightField object value")
    func present() async {
        subject.loadViewIfNeeded()
        let url1 = URL(string: "http://www.example1.com")!
        let url2 = URL(string: "http://www.example2.com")!
        var state = MainState()
        state.leftFolder = url1
        state.rightFolder = url2
        await subject.present(state)
        #expect(subject.leftField.objectValue as? URL == url1)
        #expect(subject.rightField.objectValue as? URL == url2)
    }

    @Test("present: sets leftSelected, rightSelected, arrow image")
    func presentLeftRightArrow() async {
        subject.loadViewIfNeeded()
        subject.leftSelected.stringValue = "left"
        subject.rightSelected.stringValue = "right"
        subject.arrow.image = NSImage(named: NSImage.computerName)!
        var state = MainState()
        await subject.present(state)
        #expect(subject.leftSelected.stringValue == "")
        #expect(subject.rightSelected.stringValue == "")
        #expect(subject.arrow.image == nil)
        state.selectedResults = [1, 2, 3]
        await subject.present(state)
        #expect(subject.leftSelected.stringValue == "")
        #expect(subject.rightSelected.stringValue == "")
        #expect(subject.arrow.image == nil)
        state.selectedResults = [0]
        state.results = [Entry(copyFrom: URL(string: "file:///a/b")!, copyTo: URL(string: "file:///c/d")!, why: .absentRight)]
        await subject.present(state)
        #expect(subject.leftSelected.stringValue == "/\u{200B}a/\u{200B}b")
        #expect(subject.rightSelected.stringValue == "/\u{200B}c/\u{200B}d")
        #expect(subject.arrow.image == NSImage(named: "rightarrowgreen"))
    }

    @Test("present: if unsorted is true, empties table view sort descriptors")
    func presentSortDescriptors() async {
        subject.loadViewIfNeeded()
        subject.tableView.sortDescriptors = [NSSortDescriptor(key: "dummy", ascending: true)]
        var state = MainState()
        state.unsorted = false
        await(subject.present(state))
        #expect(subject.tableView.sortDescriptors == [NSSortDescriptor(key: "dummy", ascending: true)])
        state.unsorted = true
        await(subject.present(state))
        #expect(subject.tableView.sortDescriptors == [])
    }

    @Test("present: presents to datasource")
    func presentDatasource() async {
        subject.loadViewIfNeeded()
        let url1 = URL(string: "http://www.example1.com")!
        let url2 = URL(string: "http://www.example2.com")!
        var state = MainState()
        state.leftFolder = url1
        state.rightFolder = url2
        await subject.present(state)
        #expect(datasource.methodsCalled == ["present(_:)"])
        #expect(datasource.statePresented == state)
    }

    @Test("receive currentFolder: populates and shows, or hides, progress interface")
    func currentFolder() async {
        subject.loadViewIfNeeded()
        await subject.receive(.currentFolder("howdy"))
        #expect(!subject.nowProcessing.isHidden)
        #expect(!subject.currentFolder.isHidden)
        #expect(!subject.cancelButton.isHidden)
        #expect(subject.currentFolder.stringValue == "howdy")
        await subject.receive(.currentFolder(nil))
        #expect(subject.nowProcessing.isHidden)
        #expect(subject.currentFolder.isHidden)
        #expect(subject.cancelButton.isHidden)
    }

    @Test("textFieldChanged: sends left/right field changed depending on sender")
    func textFieldChanged() async {
        subject.loadViewIfNeeded()
        let url1 = URL(string: "http://www.example1.com")!
        let url2 = URL(string: "http://www.example2.com")!
        subject.leftField.objectValue = url1
        subject.rightField.objectValue = url2
        subject.textFieldChanged(subject.leftField!)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.leftFieldChanged(url1)])
        processor.thingsReceived = []
        subject.textFieldChanged(subject.rightField!)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.rightFieldChanged(url2)])
    }

    @Test("leftFieldChoose: sends left field choose with sender's window")
    func leftFieldChoose() async {
        let view = NSView()
        let window = makeWindow(view: view)
        subject.leftFieldChoose(view)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.leftFieldChoose(window)])
        closeWindows()
    }

    @Test("rightFieldChoose: sends right field choose with sender's window")
    func rightFieldChoose() async {
        let view = NSView()
        let window = makeWindow(view: view)
        subject.rightFieldChoose(view)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.rightFieldChoose(window)])
        closeWindows()
    }

    @Test("preflight: sends preflight")
    func preflight() async {
        subject.preflight(self)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.preflight])
    }
}
