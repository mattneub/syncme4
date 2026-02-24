import Foundation

/// An Entry is a single operation-to-be-performed; this what preflighting creates a list of,
/// and thus is also what is represented by the preflight table, and at the same time it states
/// what to do when the time comes to perform the action.
nonisolated struct Entry: Equatable {
    // unique id so that we can use a diffable data source

    let id = UUID()

    // Actual item URLs

    var copyFrom: URL // item that is source
    var copyTo: URL // item that is destination

    var why: Reason // var, because we can change reason later

    // Directional (spatial) representations to show the user the pathnames
    // in the left folder and the right folder, respectively.

    var leftFolderItemPath: String {
        let leftToRight = why.imageName.hasPrefix("right")
        return (leftToRight ? copyFrom : copyTo).path(percentEncoded: false)
    }
    var rightFolderItemPath: String {
        let leftToRight = why.imageName.hasPrefix("right")
        return (leftToRight ? copyTo : copyFrom).path(percentEncoded: false)
    }

    // Index number so we can restore the original sort order
    var originalOrder = 0

    init(copyFrom: URL, copyTo: URL, why: Reason) {
        self.copyFrom = copyFrom
        self.copyTo = copyTo
        self.why = why
    }
}
