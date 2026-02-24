/// A Reason is a reason why an Entry appears in the list of things that need to be
/// reconciled. It has an Int raw value because case order is sort order, and so
/// we can map to raw value and sort on that. It also provides a mapping from a
/// reason to the image representing it, via its string name.
nonisolated enum Reason: Int {
    case absentRight
    case olderRight
    case absentLeft
    case olderLeft
    var imageName: String {
        switch self {
        case .olderRight : return "rightarrowred"
        case .olderLeft : return "leftarrowred"
        case .absentRight : return "rightarrowgreen"
        case .absentLeft : return "leftarrowgreen"
        }
    }
}

