import AppKit

/// Table view data source and delegate for the view controller's table view.
final class PrefsDatasource: NSObject, @MainActor TableViewDatasourceType {
    typealias State = PrefsState
    typealias Received = PrefsEffect

    /// Processor to whom we can send action messages.
    weak var processor: (any Receiver<PrefsAction>)?

    /// Weak reference to the table view.
    weak var tableView: NSTableView?

    init(tableView: NSTableView, processor: (any Receiver<PrefsAction>)?) {
        self.tableView = tableView
        self.processor = processor
        super.init()
        datasource = createDataSource(tableView: tableView)
        tableView.dataSource = datasource
        tableView.delegate = self
    }

    /// Type alias for the type of the data source, for convenience.
    typealias DatasourceType = SortableDiffableDataSource

    /// Retain the diffable data source.
    var datasource: DatasourceType!

    func createDataSource(tableView: NSTableView) -> DatasourceType {
        let datasource = DatasourceType.init(
            tableView: tableView
        ) { [unowned self] tableView, tableColumn, row, identifier in
            viewProvider(tableView, tableColumn, row, identifier)
        }
        return datasource
    }

    var data = [StopListItem]()

    func present(_ state: PrefsState) async {
        configureData(state)
    }

    func receive(_ effect: PrefsEffect) async {
        switch effect {
        case .changed(let row, let text):
            data[row].name = text
        case .editLastRow:
            let lastRow = data.count - 1
            tableView?.editColumn(0, row: lastRow, with: nil, select: true)
        }
    }

    func configureData(_ state: PrefsState) {
        let data = state.stopListItems
        if data == self.data {
            return // nothing to do, don't update the table unnecessarily
        }
        self.data = data
        var snapshot = datasource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections(["dummy"])
        snapshot.appendItems(data.map(\.id))
        datasource.apply(snapshot, animatingDifferences: false)
    }

    func viewProvider(_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ identifier: UUID) -> NSView {
        let view = tableView.makeView(withIdentifier: tableColumn.identifier, owner: tableView) as? NSTableCellView
        let item = data[row]
        view?.textField?.stringValue = item.name
        view?.textField?.action = Selector(("didEndEditing:"))
        view?.textField?.maximumNumberOfLines = 1
        return view ?? NSView()
    }
}
