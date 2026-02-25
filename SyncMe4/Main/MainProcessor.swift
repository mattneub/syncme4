final class MainProcessor: Processor {
    weak var presenter: (any ReceiverPresenter<Void, MainState>)?

    weak var coordinator: (any RootCoordinatorType)?

    var state = MainState()

    func receive(_ action: MainAction) async {
        switch action {
        case .leftFieldChanged(let url):
            state.leftFolder = url
        case .leftFieldChoose(let window):
            if let url = await services.openPanelOpener.chooseFolder(window: window) {
                state.leftFolder = url
                await presenter?.present(state)
            }
        case .preflight:
            guard let url1 = state.leftFolder, let url2 = state.rightFolder else {
                services.beeper.beep()
                return
            }
            do {
                let results = try await services.preflighter.compareFolders(folder1: url1, folder2: url2)
                state.results = results
                await presenter?.present(state)
            } catch {
                print(error) // TODO: do something useful with error
            }
        case .rightFieldChanged(let url):
            state.rightFolder = url
        case .rightFieldChoose(let window):
            if let url = await services.openPanelOpener.chooseFolder(window: window) {
                state.rightFolder = url
                await presenter?.present(state)
            }
        case .selectedRows(let indexSet):
            state.selectedResults = indexSet
            await presenter?.present(state)
        }
    }
}
