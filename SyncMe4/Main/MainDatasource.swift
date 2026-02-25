import AppKit

/// Table view data source and delegate for the view controller's table view.
final class MainDatasource: NSObject, @MainActor TableViewDatasourceType {
    typealias State = MainState
    typealias Received = Void

    /// Processor to whom we can send action messages.
    weak var processor: (any Receiver<MainAction>)?

    /// Weak reference to the table view.
    weak var tableView: NSTableView?

    init(tableView: NSTableView, processor: (any Receiver<MainAction>)?) {
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
        datasource.processor = processor
        return datasource
    }

    var data = [Entry]()

    func present(_ state: MainState) async {
        configureData(state)
    }

    func configureData(_ state: MainState) {
        let data = state.results
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
        let result = data[row] // TODO: This is wrong, we will want to use id to match
        switch tableColumn.identifier.rawValue {
        case "why":
            view?.imageView?.image = NSImage(named: result.why.imageName)
        case "path":
            view?.textField?.stringValue = result.leftFolderItemPath // TODO: this might be wrong, check original
        default: break
        }
        return view ?? NSView()
    }
}

extension MainDatasource { // table view delegate methods
    func tableViewSelectionDidChange(_ notification: Notification) {
        Task {
            await processor?.receive(.selectedRows(tableView?.selectedRowIndexes ?? []))
        }
    }
}

final class SortableDiffableDataSource: NSTableViewDiffableDataSource<String, UUID> {
    weak var processor: (any Receiver<MainAction>)?

    /// We have to implement this to prevent the compiler throwing a wobbly.
    nonisolated
    override init(tableView: NSTableView, cellProvider: @escaping NSTableViewDiffableDataSource<String, UUID>.CellProvider) {
        super.init(tableView: tableView, cellProvider: cellProvider)
    }

    /// NSTableViewDataSource optional method.
    @objc func tableView(_ tableView: NSTableView, sortDescriptorsDidChange _: [NSSortDescriptor]) {
//        Task {
//            await processor?.receive(.updateResults(tableView.sortDescriptors))
//        }
    }
}
