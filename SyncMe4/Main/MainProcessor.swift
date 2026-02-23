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
        case .rightFieldChanged(let url):
            state.rightFolder = url
        case .rightFieldChoose(let window):
            if let url = await services.openPanelOpener.chooseFolder(window: window) {
                state.rightFolder = url
                await presenter?.present(state)
            }
        }
    }
}
