final class PrefsProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?

    weak var presenter: (any ReceiverPresenter<PrefsEffect, PrefsState>)?

    var state = PrefsState()

    func receive(_ action: PrefsAction) async {
        switch action {
        case .add:
            state.stopListItems.append(.init(name: ""))
            await presenter?.present(state)
            await presenter?.receive(.editLastRow)
        case .cancel:
            coordinator?.closePrefs()
        case .changed(let row, let text):
            state.stopListItems[row].name = text
            await presenter?.receive(.changed(row: row, text: text))
        case .delete(let row):
            state.stopListItems.remove(at: row)
            await presenter?.present(state)
        case .initialData:
            let items = services.persistence.loadStopList()
            state.stopListItems = items.map { StopListItem(name: $0.escapedString) }
            await presenter?.present(state)
        case .save:
            let items = state.stopListItems.map { $0.name.unescapedString }
            services.persistence.saveStopList(items)
            coordinator?.closePrefs()
        }
    }
}
