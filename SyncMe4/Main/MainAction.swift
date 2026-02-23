import AppKit

enum MainAction: Equatable {
    case leftFieldChanged(URL?)
    case leftFieldChoose(NSWindow)
    case rightFieldChanged(URL?)
    case rightFieldChoose(NSWindow)
}
