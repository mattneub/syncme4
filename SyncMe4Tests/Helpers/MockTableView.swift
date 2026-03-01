import AppKit

final class MockTableView: NSTableView {
    var methodsCalled = [String]()
    var _selectedRow: Int = 0
    var _selectedRowIndexes = IndexSet([1, 2])
    var _sortDescriptors: [NSSortDescriptor] = []
    var _numberOfRows: Int = 0
    var _rowsScrolledTo = [Int]()
    override var numberOfRows: Int { _numberOfRows }
    override var selectedRow: Int { _selectedRow }
    override var selectedRowIndexes: IndexSet { _selectedRowIndexes }
    override var sortDescriptors: [NSSortDescriptor] {
        get { _sortDescriptors }
        set {}
    }
    override func selectRowIndexes(_ indexes: IndexSet, byExtendingSelection: Bool) {
        methodsCalled.append(#function)
        _selectedRowIndexes = indexes
    }
    override func deselectAll(_ sender: Any?) {
        methodsCalled.append(#function)
    }
    override func scrollRowToVisible(_ row: Int) {
        methodsCalled.append(#function)
        _rowsScrolledTo.append(row)
    }
}
