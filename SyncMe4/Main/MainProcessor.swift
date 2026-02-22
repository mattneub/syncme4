final class MainProcessor: Processor {
    weak var presenter: (any ReceiverPresenter<Void, MainState>)?

    weak var coordinator: (any RootCoordinatorType)?

    var state = MainState()

    func receive(_ action: MainAction) async {
        switch action {

        }
    }
}
