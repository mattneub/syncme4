/// A Reason is a reason why an Entry appears in the list of things that need to be
/// reconciled. It has an Int raw value because case order is sort order, and so
/// we can map to raw value and sort on that. It also provides a mapping from a
/// reason to the image representing it, via its string name. Reasons fall naturally into
/// meaningful categories and have meaningful mutual relationships, and the enum expresses
/// these so that the client does not have to, uh, reason about them.
nonisolated enum Reason: Int {
    case absentRight
    case olderRight
    case absentLeft
    case olderLeft

    var imageName: String {
        switch self {
        case .olderRight: "rightarrowred"
        case .olderLeft: "leftarrowred"
        case .absentRight: "rightarrowgreen"
        case .absentLeft: "leftarrowgreen"
        }
    }

    var direction: Direction {
        switch self {
        case .absentRight, .olderRight: .leftToRight
        case .absentLeft, .olderLeft: .rightToLeft
        }
    }

    var opposite: Reason {
        switch self {
        case .absentRight: .absentLeft
        case .olderRight: .olderLeft
        case .absentLeft: .absentRight
        case .olderLeft: .olderRight
        }
    }

    var destinationExists: Bool {
        switch self {
        case .olderRight, .olderLeft: true
        case .absentRight, .absentLeft: false
        }
    }
    
    enum Direction {
        case leftToRight
        case rightToLeft
    }
}

