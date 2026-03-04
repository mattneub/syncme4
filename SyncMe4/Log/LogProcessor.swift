import Observation

final class LogProcessor: Processor {
    weak var presenter: (any ReceiverPresenter<Void, LogState>)?

    weak var coordinator: (any RootCoordinatorType)?

    var state = LogState()

    var cancellableTask: Task<Void, Never>?

    func receive(_ action: LogAction) async {
        switch action {
        case .initialData:
            observeLog()
        }
    }

    /// This is the only thing we do: watch the Log. We capture `self` weakly because otherwise
    /// we will just leak when the coordinator nilifies its reference to us.
    func observeLog() {
        cancellableTask = Task { [weak self] in
            let observations = Observations {
                services.log.log
            }
            for await text in observations {
                if Task.isCancelled {
                    break
                }
                guard let self else {
                    break
                }
                state.text = text == "" ? "No errors." : text
                await presenter?.present(state)
            }
        }
    }

    deinit {
        cancellableTask?.cancel()
        print("farewell from log processor")
    }
}
