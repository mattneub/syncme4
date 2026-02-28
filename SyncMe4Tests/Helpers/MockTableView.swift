import AppKit

final class MockTableView: NSTableView {
    var methodsCalled = [String]()
    var _selectedRow: Int = 0
    var _selectedRowIndexes = IndexSet([1, 2])
    var _sortDescriptors: [NSSortDescriptor] = []
    var _numberOfRows: Int = 0
    var _indexSet: IndexSet?
    var _animationOptions: NSTableView.AnimationOptions?
    override var numberOfRows: Int { _numberOfRows }
    override var selectedRow: Int { _selectedRow }
    override var selectedRowIndexes: IndexSet { _selectedRowIndexes }
    override var sortDescriptors: [NSSortDescriptor] {
        get { _sortDescriptors }
        set {}
    }
    override func removeRows(at indexSet: IndexSet, withAnimation animationOptions: NSTableView.AnimationOptions) {
        methodsCalled.append(#function)
        self._indexSet = indexSet
        self._animationOptions = animationOptions
    }
}
