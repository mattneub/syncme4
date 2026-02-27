import AppKit

enum MainAction: Equatable {
    case leftFieldChanged(URL?)
    case leftFieldChoose(NSWindow)
    case preflight
    case removeFromList(IndexSet)
    case rightFieldChanged(URL?)
    case rightFieldChoose(NSWindow)
    case selectedRows(IndexSet)
    case unsort
    case updateResults([NSSortDescriptor])
}
