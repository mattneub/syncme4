import AppKit

protocol SorterType {
    func sort(_ entries: [Entry], using sortDescriptors: [NSSortDescriptor]) -> [Entry]
}

/// Object that sorts Entry array from NSSortDescriptors emitted by the table view.
/// This relieves the MainProcessor from having to know anything about sorting and sort descriptors
/// (and of course makes everything easier to test).
final class Sorter: SorterType {
    func sort(_ entries: [Entry], using sortDescriptors: [NSSortDescriptor]) -> [Entry] {
        guard sortDescriptors.count > 0 else {
            return entries.sorted { $0.originalOrder < $1.originalOrder }
        }
        let descriptor = sortDescriptors[0]
        guard let key = descriptor.key else {
            return entries
        }
        let ascending = descriptor.ascending
        let direction: ComparisonResult = (ascending ? .orderedAscending : .orderedDescending)
        switch key {
        case "path": return entries.sorted {
            $0.leftFolderItemPath.localizedStandardCompare($1.leftFolderItemPath) == direction
        }
        case "why": return entries.sorted {
            ascending ? $0.why.rawValue < $1.why.rawValue : $0.why.rawValue > $1.why.rawValue
        }
        default: return entries // shouldn't happen, since what else could it be?
        }
    }
}
