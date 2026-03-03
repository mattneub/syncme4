enum PrefsEffect: Equatable {
    case changed(row: Int, text: String)
    case editLastRow
}
