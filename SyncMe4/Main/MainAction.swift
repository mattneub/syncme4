import AppKit

enum MainAction: Equatable {
    case leftFieldChanged(URL?)
    case leftFieldChoose(NSWindow)
    case preflight
    case removeFromList(IndexSet)
    case rightFieldChanged(URL?)
    case rightFieldChoose(NSWindow)
    case selectedRows(IndexSet)
    case tickle
    case unsort
    case updateResults([NSSortDescriptor])
}
