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
                // TODO: there may be other things we need to do here, such as disable everything
                // (like the Preflight button, choose buttons, etc.)
                // so far, however, the comparison is so fast that it doesn't even matter
                state.selectedResults = []
                state.results = []
                await presenter?.present(state)
                // start watching as the results pour in
                observePreflighter()
                var results = try await services.preflighter.compareFolders(folder1: url1, folder2: url2)
                // annotate and display the results
                results = results.enumerated().map { index, result in
                    var result = result
                    result.originalOrder = index
                    return result
                }
                state.results = results
                state.unsorted = true
                await presenter?.present(state)
            } catch {
                progressWatchingTask?.cancel()
                print(error) // TODO: do something useful with error
            }
        case .removeFromList(let indexes):
            indexes.map { Int($0) }.sorted { $0 > $1 }.forEach {
                state.results.remove(at: $0)
            }
            state.selectedResults = []
            await presenter?.present(state)
        case .reveal(let index):
            let entry = state.results[index]
            services.finderScripter.reveal(entry.copyFrom)
        case .revealTarget(let index):
            let entry = state.results[index]
            services.finderScripter.reveal(entry.copyTo)
        case .reverseDirection(let index):
            var entry = state.results[index]
            guard entry.why == .olderLeft || entry.why == .olderRight else {
                services.beeper.beep()
                return
            }
            entry.why = entry.why == .olderLeft ? .olderRight : .olderLeft
            swap(&entry.copyFrom, &entry.copyTo)
            state.results[index] = entry
            await presenter?.present(state)
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
        case .tickle:
            services.finderScripter.tickle()
        case .unsort:
            state.selectedResults = []
            state.results = services.sorter.sort(state.results, using: [])
            state.unsorted = true
            await presenter?.present(state)
        case .updateResults(let sortDescriptors):
            state.selectedResults = []
            state.results = services.sorter.sort(state.results, using: sortDescriptors)
            state.unsorted = false
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
