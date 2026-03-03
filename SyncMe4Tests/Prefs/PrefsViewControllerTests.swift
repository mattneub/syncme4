@testable import SyncMe4
import Testing
import AppKit
import WaitWhile

struct PrefsViewControllerTests {
    let subject = PrefsViewController()
    let processor = MockProcessor<PrefsAction, PrefsState, PrefsEffect>()
    let datasource = MockPrefsDatasource()
    let tableView = MockTableView()

    init() {
        subject.processor = processor
        subject.datasource = datasource
        subject.tableView = tableView
    }

    @Test("initialize: configures real datasource")
    func initialize() throws {
        let subject = PrefsViewController()
        subject.tableView = tableView
        subject.processor = processor
        let datasource = try #require(subject.datasource as? PrefsDatasource)
        #expect(datasource.processor === processor)
        #expect(datasource.tableView === tableView)
    }

    @Test("viewDidLoad: sends initialData")
    func viewDidLoad() async {
        subject.viewDidLoad()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.initialData])
    }

    @Test("present: presents to the datasource")
    func present() async {
        let state = PrefsState(stopListItems: [.init(name: "Groucho")])
        await subject.present(state)
        #expect(datasource.statePresented == state)
    }

    @Test("receive: forwards to the datasource")
    func receive() async {
        await subject.receive(.editLastRow)
        #expect(datasource.thingsReceived == [.editLastRow])
    }

    @Test("doAdd: ends editing, sends add")
    func doAdd() async throws {
        let window = makeWindow(viewController: subject)
        let textField = NSTextField()
        subject.view.addSubview(textField)
        textField.becomeFirstResponder()
        let editor = try #require(window.fieldEditor(false, for: textField))
        #expect(window.firstResponder === editor)
        subject.doAdd(NSButton())
        #expect(window.firstResponder == window)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .add)
    }

    @Test("doDelete: ends editing, sends delete for selected row")
    func doDelete() async throws {
        makeWindow(viewController: subject)
        let textField = NSTextField()
        subject.view.addSubview(textField)
        textField.becomeFirstResponder()
        #expect(textField.currentEditor() != nil)
        let tableView = MockTableView()
        tableView._selectedRow = 10
        subject.tableView = tableView
        subject.doDelete(NSButton())
        #expect(textField.currentEditor() == nil)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .delete(row: 10))
    }

    @Test("doDelete: if no selected row, does nothing")
    func doDeleteNoSelection() async throws {
        makeWindow(viewController: subject)
        let textField = NSTextField()
        subject.view.addSubview(textField)
        textField.becomeFirstResponder()
        #expect(textField.currentEditor() != nil)
        let tableView = MockTableView()
        tableView._selectedRow = -1
        subject.tableView = tableView
        subject.doDelete(NSButton())
        try? await Task.sleep(for: .seconds(0.1))
        #expect(textField.currentEditor() != nil)
        #expect(processor.thingsReceived == [.initialData])
    }

    @Test("doCancel: sends cancel")
    func doCancel() async {
        subject.doCancel(NSButton())
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.cancel])
    }

    @Test("doSave: ends editing, sends save")
    func doSave() async {
        makeWindow(viewController: subject)
        let textField = NSTextField()
        subject.view.addSubview(textField)
        textField.becomeFirstResponder()
        #expect(textField.currentEditor() != nil)
        let tableView = MockTableView()
        tableView._selectedRow = 10
        subject.tableView = tableView
        subject.doSave(NSButton())
        #expect(textField.currentEditor() == nil)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .save)
    }

    @Test("didEndEditing: sends changed for sender text field")
    func didEndEditing() async throws {
        subject.loadViewIfNeeded()
        let tableView = MockTableView()
        tableView._rowForView = 20
        subject.tableView = tableView
        let textField = NSTextField()
        textField.stringValue = "howdy"
        subject.didEndEditing(textField)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .changed(row: 20, text: "howdy"))
    }

}
