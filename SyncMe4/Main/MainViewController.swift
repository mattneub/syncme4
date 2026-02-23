import AppKit

final class MainViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<MainAction>)?

    @IBOutlet var leftField: NSTextField!

    @IBOutlet var rightField: NSTextField!

    override var nibName: NSNib.Name? { "Main" }

    func present(_ state: MainState) async {
        if state.leftFolder != leftField.objectValue as? URL {
            leftField.objectValue = state.leftFolder
        }
        if state.rightFolder != rightField.objectValue as? URL {
            rightField.objectValue = state.rightFolder
        }
    }

    @IBAction func textFieldChanged(_ sender: Any) {
        if let tf = sender as? NSTextField {
            switch tf {
            case leftField: Task {
                await processor?.receive(.leftFieldChanged(tf.objectValue as? URL))
            }
            case rightField: Task {
                await processor?.receive(.rightFieldChanged(tf.objectValue as? URL))
            }
            default: break
            }
        }
    }

    @IBAction func leftFieldChoose(_ sender: Any) {
        Task {
            if let window = (sender as? NSView)?.window {
                await processor?.receive(.leftFieldChoose(window))
            }
        }
    }

    @IBAction func rightFieldChoose(_ sender: Any) {
        Task {
            if let window = (sender as? NSView)?.window {
                await processor?.receive(.rightFieldChoose(window))
            }
        }
    }
}
