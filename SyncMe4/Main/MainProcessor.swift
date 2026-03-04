import Foundation

final class MainProcessor: Processor {
    weak var presenter: (any ReceiverPresenter<MainEffect, MainState>)?

    weak var coordinator: (any RootCoordinatorType)?

    var state = MainState()

    /// Task that observes changes in the current folder being processed by the preflighter.
    var progressWatchingTask: Task<Void, Never>?

    func receive(_ action: MainAction) async {
        switch action {
        case .copyAll:
            await copyAll()
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
            await preflight(url1, url2)
        case .removeFromList(let indexes):
            indexes.sorted(by: >).forEach {
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
            guard entry.why.destinationExists else {
                services.beeper.beep()
                return
            }
            entry.why = entry.why.opposite
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
        case .trash(let indexSet):
            await trash(indexSet, target: false)
        case .trashTarget(let indexSet):
            // meaningless to trash the target if there is no target, so require that _all_
            // selected entries have destinations
            guard indexSet.map({ state.results[$0] }).allSatisfy({ $0.why.destinationExists }) else {
                services.beeper.beep()
                return
            }
            await trash(indexSet, target: true)
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

    /// Implementation of `.preflight`.
    func preflight(_ url1: URL, _ url2: URL) async {
        do {
            // clear the decks
            state.selectedResults = []
            state.results = []
            state.disabled = true
            await presenter?.present(state)
            // start watching as the results pour in
            observePreflighter()
            let stopList = services.persistence.loadStopList()
            var results = try await services.preflighter.compareFolders(
                folder1: url1,
                folder2: url2,
                stopList: stopList
            )
            // annotate and display the results
            results = results.enumerated().map { index, result in
                var result = result
                result.originalOrder = index
                return result
            }
            state.results = results
            state.unsorted = true
            state.disabled = false
            await presenter?.present(state)
        } catch {
            progressWatchingTask?.cancel()
            state.disabled = false
            await presenter?.present(state)
            await presenter?.receive(.currentFolder(nil))
            services.log.append(String(describing: error))
            coordinator?.showLog()
        }
    }

    /// Implementation of receive `.trash` and `.trashTarget`.
    func trash(_ indexSet: IndexSet, target: Bool) async {
        state.disabled = true
        await presenter?.present(state)
        var indexes = indexSet.sorted(by: <)
        do {
            while !indexes.isEmpty {
                await presenter?.receive(.scrollToRow(indexes[0]))
                let keyPath: KeyPath<Entry, URL> = target ? \.copyTo : \.copyFrom
                let url = state.results[indexes[0]][keyPath: keyPath]
                try await Task { @concurrent in
                    try await services.finderScripter.trash(url)
                    // try await Task.sleep(for: .seconds(1))
                }.value
                state.results.remove(at: indexes[0])
                indexes.remove(at: 0)
                indexes = indexes.map { $0 - 1 }
                state.selectedResults = IndexSet(indexes)
                await presenter?.present(state)
            }
        } catch {
            services.log.append(String(describing: error))
            coordinator?.showLog()
        }
        state.disabled = false
        await presenter?.present(state)
    }

    /// Implementation of `.copyAll`.
    func copyAll() async {
        state.disabled = true
        await presenter?.present(state)
        await presenter?.receive(.deselectAllAndScrollToTop)
        do {
            while !state.results.isEmpty {
                try? await ifTesting {
                    try? await Task.sleep(for: .seconds(0.2))
                }
                try Task.checkCancellation()
                await presenter?.receive(.selectFirstRow)
                let entry = state.results[0]
                let currentFolder = entry.sourcePath
                await presenter?.receive(.currentFolder(currentFolder))
                try await Task { @concurrent in
                    try await services.finderScripter.copy(from: entry.copyFrom, to: entry.copyTo)
                    // try await Task.sleep(for: .seconds(1))
                }.value
                state.results.remove(at: 0)
                state.selectedResults = []
                await presenter?.present(state)
            }
        } catch {
            services.log.append(String(describing: error))
            coordinator?.showLog()
        }
        await presenter?.receive(.currentFolder(nil))
        state.disabled = false
        await presenter?.present(state)
    }
}
