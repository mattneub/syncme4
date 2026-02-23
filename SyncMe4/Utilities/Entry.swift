/// An Entry is a single operation-to-be-performed; this what preflighting creates a list of,
/// and thus is also what is represented by the preflight table, and at the same time it states
/// what to do when the time comes to perform the action.
struct Entry {
    // Actual pathnames

    var copyFrom: String // pathname for finder item that is source
    var copyTo: String // pathname for finder item that is destination

    var why: Reason // var, because we can change reason later

    // Directional (spatial) representations to show the user the pathnames; each is either
    // copyFrom or copyTo, depending on which way the arrow points
    // TODO: Surely these could be computed vars?

    let left: String
    let right: String

    // Index number so we can restore the original sort order
    var originalOrder = 0

    init(copyFrom: String, copyTo: String, why: Reason) {
        self.copyFrom = copyFrom
        self.copyTo = copyTo
        self.why = why
        // and we also need a _spatial_ representation
        let leftToRight = why.imageName.hasPrefix("right")
        self.left = leftToRight ? copyFrom : copyTo
        self.right = leftToRight ? copyTo : copyFrom
    }
}
