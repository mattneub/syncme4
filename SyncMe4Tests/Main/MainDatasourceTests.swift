@testable import SyncMe4
import Testing
import AppKit
import WaitWhile

private struct MainDatasourceTests {
    let subject: MainDatasource!
    let processor = MockReceiver<MainAction>()
    let tableView: NSTableView!

    init() {
        // Dumpster-dive the Main nib to get the table view that is configured there.
        let viewController = MyViewController()
        viewController.loadViewIfNeeded()
        tableView = viewController.tableView
        subject = MainDatasource(tableView: tableView, processor: processor)
    }

    @Test("Initialization: creates and configures the data source, configures the table view")
    func initialize() throws {
        let datasource = try #require(subject.datasource)
        #expect(tableView.dataSource === datasource)
        #expect(tableView.delegate === subject)
    }

    @Test("present: configures the contents of the data source")
    func present() async {
        let result = Entry(copyFrom: URL(string: "file:///a/b")!, copyTo: URL(string: "file:///c/d")!, why: .olderLeft)
        await subject.present(MainState(results: [result]))
        #expect(subject.data == [result])
        let snapshot = subject.datasource.snapshot()
        #expect(snapshot.sectionIdentifiers == ["dummy"])
        #expect(snapshot.itemIdentifiers(inSection: "dummy") == [result.id])
    }

    @Test("rows are correctly constructed")
    func rows() async throws {
        let result = Entry(copyFrom: URL(string: "file:///a/b")!, copyTo: URL(string: "file:///c/d")!, why: .olderLeft)
        await subject.present(MainState(results: [result]))
        await #while(tableView.numberOfRows < 1)
        do {
            let view = try #require(tableView.view(atColumn: 1, row: 0, makeIfNecessary: false) as? NSTableCellView)
            #expect(view.imageView?.image == NSImage(named: "leftarrowred"))
        }
        do {
            let view = try #require(tableView.view(atColumn: 0, row: 0, makeIfNecessary: false) as? NSTableCellView)
            #expect(view.textField?.stringValue == "/c/d") // TODO: is this the right answer?
        }
    }

    @Test("selectionChanged: sends selectedRows to processor")
    func selectionChanged() async {
        let tableView = MockTableView()
        tableView._selectedRowIndexes = [3]
        subject.tableView = tableView
        subject.tableViewSelectionDidChange(Notification(name: .init("dummy")))
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.selectedRows([3])])
    }

    @Test("datasource sortDescriptorsDidChange: sends updateResults to processor")
    func sortDescriptorsDidChange() async throws {
//        let tableView = MockTableView()
//        let sortDescriptor = NSSortDescriptor(key: "howdy", ascending: false)
//        tableView._sortDescriptors = [sortDescriptor]
//        let datasource = try #require(subject.datasource)
//        let datasourceProcessor = try #require(datasource.processor)
//        #expect(datasourceProcessor === processor)
//        datasource.tableView(tableView, sortDescriptorsDidChange: [])
//        await #while(processor.thingsReceived.isEmpty)
//        #expect(processor.thingsReceived == [.updateResults([sortDescriptor])])
    }
}

/// Ersatz view controller used to dumpster-dive the Results nib.
private final class MyViewController: NSViewController {
    override var nibName: String? { get {"Main"} set {}}
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var leftField: NSTextField!
    @IBOutlet var rightField: NSTextField!
    @IBOutlet var leftSelected: NSTextField!
    @IBOutlet var rightSelected: NSTextField!
    @IBOutlet var cancelButton: NSButton!
    @IBOutlet var currentFolder: NSTextField!
    @IBOutlet var nowProcessing: NSTextField!
    @IBOutlet var arrow: NSImageView!
    @IBAction func textFieldChanged(_ sender: Any) {}
    @IBAction func leftFieldChoose(_ sender: Any) {}
    @IBAction func rightFieldChoose(_ sender: Any) {}
    @IBAction func preflight(_ sender: Any) {}
}

private final class MockTableView: NSTableView {
    var _selectedRow: Int = 0
    var _selectedRowIndexes = IndexSet([1, 2])
    var _sortDescriptors: [NSSortDescriptor] = []
    override var selectedRow: Int { _selectedRow }
    override var selectedRowIndexes: IndexSet { _selectedRowIndexes }
    override var sortDescriptors: [NSSortDescriptor] {
        get { _sortDescriptors }
        set {}
    }
}
