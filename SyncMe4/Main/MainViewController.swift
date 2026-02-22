import AppKit

final class MainViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<MainAction>)?

    override var nibName: NSNib.Name? { "Main" }

    func present(_ state: MainState) async {}
}
