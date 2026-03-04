import AppKit

final class LogViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<LogAction>)?

    @IBOutlet var textView: NSTextView! {
        didSet {
            textView.string = "No errors."
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await processor?.receive(.initialData)
        }
    }

    func present(_ state: LogState) async {
        textView.string = state.text
        textView.scrollToEndOfDocument(self)
    }

    deinit {
        print("farewell from log view controller")
    }
}
