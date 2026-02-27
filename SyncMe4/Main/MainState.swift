import Foundation

struct MainState: Equatable {
    var leftFolder: URL?
    var rightFolder: URL?

    var results = [Entry]()

    var selectedResults = IndexSet()

    var selectedResult: Entry? {
        selectedResults.count == 1 ? results[selectedResults[selectedResults.startIndex]] : nil
    }
    var leftPath: String? {
        selectedResult?.leftFolderItemPath.urlWrap
    }
    var rightPath: String? {
        selectedResult?.rightFolderItemPath.urlWrap
    }
    var arrow: String? {
        selectedResult?.why.imageName
    }

    /// When true, the table view's sort descriptors should be emptied.
    var unsorted = true
}
