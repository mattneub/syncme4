enum MainEffect: Equatable {
    case currentFolder(String?)
    case deselectAllAndScrollToTop
    case scrollToRow(Int)
    case selectFirstRow
}
