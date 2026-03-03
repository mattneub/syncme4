import AppKit

final class PrefsViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<PrefsAction>)?

    func present(_ state: PrefsState) async {}

    @IBAction func doCancel(_ sender: Any) {
        print("cancel")
    }

    deinit {
        print("farewell from prefs view controller")
    }

}
