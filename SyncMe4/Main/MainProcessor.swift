import Foundation

final class MainProcessor: Processor {
    weak var presenter: (any ReceiverPresenter<MainEffect, MainState>)?

    weak var coordinator: (any RootCoordinatorType)?

    var state = MainState()

    /// Task that observes changes in the current folder being processed by the preflighter.
    var progressWatchingTask: Task<Void, Never>?

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
                // clear the decks
                // TODO: there may be other things we need to do here, such as disable everything (like the Preflight button, choose buttons, etc.)
                state.selectedResults = []
                state.results = []
                await presenter?.present(state)
                // start watching as the results pour in
                observePreflighter()
                let results = try await services.preflighter.compareFolders(folder1: url1, folder2: url2)
                // display the results
                state.results = results
                await presenter?.present(state)
            } catch {
                progressWatchingTask?.cancel()
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

    /// Prepare and start observing preflighter `currentFolder`, and stop when you get `nil` or
    /// the task is cancelled.
    func observePreflighter() {
        let preflighter = services.preflighter
        preflighter.prepare()
        let progress = Observations {
            return preflighter.currentFolder
        }
        progressWatchingTask?.cancel() // just in case
        progressWatchingTask = Task {
            for await currentFolder in progress {
                await presenter?.receive(.currentFolder(currentFolder))
                if currentFolder == nil || Task.isCancelled {
                    progressWatchingTask?.cancel()
                    break
                }
            }
        }
    }
}
