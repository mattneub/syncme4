import AppKit

final class MockTableView: NSTableView {
    var _selectedRow: Int = 0
    var _selectedRowIndexes = IndexSet([1, 2])
    var _sortDescriptors: [NSSortDescriptor] = []
    var _numberOfRows: Int = 0
    override var numberOfRows: Int { _numberOfRows }
    override var selectedRow: Int { _selectedRow }
    override var selectedRowIndexes: IndexSet { _selectedRowIndexes }
    override var sortDescriptors: [NSSortDescriptor] {
        get { _sortDescriptors }
        set {}
    }
}
