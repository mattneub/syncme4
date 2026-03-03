enum PrefsAction: Equatable {
    case add
    case cancel
    case changed(row: Int, text: String)
    case delete(row: Int)
    case initialData
    case save
}
