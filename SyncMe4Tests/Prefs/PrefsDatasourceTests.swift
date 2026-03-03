@testable import SyncMe4
import Testing
import AppKit
import WaitWhile

private struct PrefsDatasourceTests {
    let subject: PrefsDatasource!
    let processor = MockReceiver<PrefsAction>()
    let tableView: NSTableView!

    init() {
        // Dumpster-dive the Prefs nib to get the table view that is configured there.
        var array: NSArray? // the window, the view controller, and the application
        let owner = MyWindowController()
        NSNib(nibNamed: "Prefs", bundle: nil)?.instantiate(withOwner: owner, topLevelObjects: &array)
        let viewController = owner.viewController
        viewController?.loadViewIfNeeded()
        tableView = viewController?.tableView
        subject = PrefsDatasource(tableView: tableView, processor: processor)
    }

    @Test("Initialization: creates and configures the data source, configures the table view")
    func initialize() throws {
        let datasource = try #require(subject.datasource)
        #expect(tableView.dataSource === datasource)
        #expect(tableView.delegate === subject)
    }

    @Test("present: configures the contents of the data source")
    func present() async {
        let item = StopListItem(name: "Groucho")
        await subject.present(PrefsState(stopListItems: [item]))
        #expect(subject.data == [item])
        let snapshot = subject.datasource.snapshot()
        #expect(snapshot.sectionIdentifiers == ["dummy"])
        #expect(snapshot.itemIdentifiers(inSection: "dummy") == [item.id])
    }

    @Test("rows are correctly constructed")
    func rows() async throws {
        let item = StopListItem(name: "Groucho")
        await subject.present(PrefsState(stopListItems: [item]))
        await #while(tableView.numberOfRows < 1)
        let view = try #require(tableView.view(atColumn: 0, row: 0, makeIfNecessary: false) as? NSTableCellView)
        #expect(view.textField?.stringValue == "Groucho")
    }

    @Test("receive changed: changes name in given row of data")
    func changed() async {
        let item1 = StopListItem(name: "Groucho")
        let item2 = StopListItem(name: "Harpo")
        await subject.present(PrefsState(stopListItems: [item1, item2]))
        await subject.receive(.changed(row: 1, text: "Chico"))
        #expect(subject.data[1].name == "Chico")
    }

    @Test("receive editLastRow: opens text field of last row for editing")
    func editLastRow() async throws {
        makeWindow(view: tableView)
        let item = StopListItem(name: "Groucho")
        let state = PrefsState(stopListItems: [item])
        await subject.present(state)
        await subject.receive(.editLastRow)
        let view = try #require(tableView.view(atColumn: 0, row: 0, makeIfNecessary: false) as? NSTableCellView)
        let field = try #require(view.textField)
        #expect(field.currentEditor() != nil)
        #expect(field.currentEditor()?.selectedRange == .init(location: 0, length: 7))
    }
}

/// Ersatz window controller used to dumpster-dive the Prefs nib.
private final class MyWindowController: NSWindowController {
    @IBOutlet var viewController: PrefsViewController!
}

