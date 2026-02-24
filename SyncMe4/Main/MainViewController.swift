import AppKit
import SwiftAutomation
import MacOSGlues

final class MainViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<MainAction>)?

    @IBOutlet var leftField: NSTextField!

    @IBOutlet var rightField: NSTextField!

    @IBOutlet weak var tableView: NSTableView!

    lazy var datasource: (any TableViewDatasourceType<Void, MainState>) = MainDatasource(
        tableView: tableView,
        processor: processor
    )

    override var nibName: NSNib.Name? { "Main" }

    override func viewDidLoad() {
        super.viewDidLoad()
        // just enough to trigger the system dialog, if needed, on launch
        let finder = Finder()
        if let name = try? finder.name.get() {
            print(name)
        } else {
            // could terminate at this point, as we have no purpose without this
        }
    }

    func present(_ state: MainState) async {
        if state.leftFolder != leftField.objectValue as? URL {
            leftField.objectValue = state.leftFolder
        }
        if state.rightFolder != rightField.objectValue as? URL {
            rightField.objectValue = state.rightFolder
        }
        await datasource.present(state)
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

    @IBAction func preflight(_ sender: Any) {
        Task {
            await processor?.receive(.preflight)
        }
    }
}
