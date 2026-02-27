import AppKit

enum MainAction: Equatable {
    case leftFieldChanged(URL?)
    case leftFieldChoose(NSWindow)
    case preflight
    case rightFieldChanged(URL?)
    case rightFieldChoose(NSWindow)
    case selectedRows(IndexSet)
    case updateResults([NSSortDescriptor])
}
