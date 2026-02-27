import AppKit

enum MainAction: Equatable {
    case leftFieldChanged(URL?)
    case leftFieldChoose(NSWindow)
    case preflight
    case removeFromList(IndexSet)
    case reveal(Int)
    case revealTarget(Int)
    case reverseDirection(Int)
    case rightFieldChanged(URL?)
    case rightFieldChoose(NSWindow)
    case selectedRows(IndexSet)
    case tickle
    case unsort
    case updateResults([NSSortDescriptor])
}
