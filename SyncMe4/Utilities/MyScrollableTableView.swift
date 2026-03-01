import AppKit

final class MyScrollableTableView: NSTableView {
    func scrollToRow(_ row: Int) {
        let headerViewHeight = headerView?.frame.height ?? 0
        let visibleHeight = visibleRect.height - headerViewHeight
        let firstVisibleRow = rows(in: visibleRect).location
        let rowHeight = rect(ofRow: firstVisibleRow).height
        let maxVisibleRows = Int(visibleHeight / rowHeight) + 1
        let maxRow = numberOfRows - 1
        let bottomRow = row + maxVisibleRows
        if bottomRow > maxRow {
            scrollRowToVisible(maxRow)
        } else {
            let yOrigin = CGFloat(row) * rowHeight - headerViewHeight
            scroll(CGPoint(x: 0, y: yOrigin))
        }
    }
}
