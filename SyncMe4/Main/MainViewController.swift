import AppKit

final class MainViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<MainAction>)?

    /// Sends a cancel signal into selected tasks that are started here.
    var cancellableTask: Task<Void, Never>?

    @IBOutlet var leftField: NSTextField!

    @IBOutlet var chooseLeftButton: NSButton!

    @IBOutlet var rightField: NSTextField!

    @IBOutlet var chooseRightButton: NSButton!

    @IBOutlet var nowProcessing: NSTextField! {
        didSet {
            nowProcessing?.isHidden = true
        }
    }

    @IBOutlet var currentFolder: NSTextField! {
        didSet {
            currentFolder?.isHidden = true
        }
    }

    @IBOutlet var cancelButton: NSButton! {
        didSet {
            cancelButton?.isHidden = true
        }
    }

    @IBOutlet var preflightButton: NSButton!

    @IBOutlet weak var tableView: NSTableView!

    @IBOutlet var leftSelected: NSTextField! {
        didSet {
            leftSelected?.stringValue = ""
        }
    }

    @IBOutlet var rightSelected: NSTextField! {
        didSet {
            rightSelected?.stringValue = ""
        }
    }

    @IBOutlet var arrow: NSImageView!

    lazy var datasource: (any TableViewDatasourceType<Void, MainState>) = MainDatasource(
        tableView: tableView,
        processor: processor
    )

    override var nibName: NSNib.Name? { "Main" }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = true
        Task {
            await processor?.receive(.tickle)
        }
    }

    func present(_ state: MainState) async {
        if state.leftFolder != leftField.objectValue as? URL {
            leftField.objectValue = state.leftFolder
        }
        if state.rightFolder != rightField.objectValue as? URL {
            rightField.objectValue = state.rightFolder
        }
        leftSelected.stringValue = state.leftPath ?? ""
        rightSelected.stringValue = state.rightPath ?? ""
        arrow.image = if let arrow = state.arrow { NSImage(named: arrow) } else { nil }
        if state.unsorted {
            tableView.sortDescriptors = []
        }
        if state.disabled {
            leftField.isEnabled = false
            chooseLeftButton.isEnabled = false
            rightField.isEnabled = false
            chooseRightButton.isEnabled = false
            preflightButton.isEnabled = false
            tableView.isEnabled = false
        } else {
            leftField.isEnabled = true
            chooseLeftButton.isEnabled = true
            rightField.isEnabled = true
            chooseRightButton.isEnabled = true
            preflightButton.isEnabled = true
            tableView.isEnabled = true
        }
        await datasource.present(state)
        // order matters
        if tableView.selectedRowIndexes != state.selectedResults {
            tableView.selectRowIndexes(state.selectedResults, byExtendingSelection: false)
        }
    }

    func receive(_ effect: MainEffect) async {
        switch effect {
        case .currentFolder(let folder):
            if let folder {
                currentFolder.stringValue = folder
                currentFolder.isHidden = false
                nowProcessing.isHidden = false
                cancelButton.isHidden = false
            } else {
                currentFolder.isHidden = true
                nowProcessing.isHidden = true
                cancelButton.isHidden = true
            }
        case .deselectAllAndScrollToTop:
            tableView.deselectAll(self)
            tableView.scrollRowToVisible(0)
        case .scrollToRow(let row):
            (tableView as? MyScrollableTableView)?.scrollToRow(row)
        case .selectFirstRow:
            tableView.selectRowIndexes([0], byExtendingSelection: false)
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

    @IBAction func preflight(_ sender: Any) {
        cancellableTask = Task {
            await processor?.receive(.preflight)
        }
    }

    @IBAction func doUnsort(_ sender: Any) {
        Task {
            await processor?.receive(.unsort)
        }
    }

    @IBAction func doRemoveFromList(_ sender: Any) {
        Task {
            await processor?.receive(.removeFromList(tableView.selectedRowIndexes))
        }
    }

    @IBAction func doReverseDirection(_ sender: Any) {
        Task {
            await processor?.receive(.reverseDirection(tableView.selectedRow))
        }
    }

    @IBAction func doReveal(_ sender: Any) {
        Task {
            await processor?.receive(.reveal(tableView.selectedRow))
        }
    }

    @IBAction func doRevealTarget(_ sender: Any) {
        Task {
            await processor?.receive(.revealTarget(tableView.selectedRow))
        }
    }

    @IBAction func doTrash(_ sender: Any) {
        Task {
            await processor?.receive(.trash(tableView.selectedRowIndexes))
        }
    }

    @IBAction func doTrashTarget(_ sender: Any) {
        Task {
            await processor?.receive(.trashTarget(tableView.selectedRowIndexes))
        }
    }

    @IBAction func doCopyAll(_ sender: Any) {
        cancellableTask = Task {
            await processor?.receive(.copyAll)
        }
    }

    @IBAction func doCancel(_ sender: Any) {
        cancellableTask?.cancel()
    }
}

extension MainViewController: NSMenuItemValidation {
    func validateMenuItem(_ item: NSMenuItem) -> Bool {
        switch item.action {
        case #selector(doUnsort): return tableView.numberOfRows > 0
        case #selector(doRemoveFromList): return tableView.selectedRowIndexes.count > 0
        case #selector(doReverseDirection): return tableView.selectedRowIndexes.count == 1
        case #selector(doReveal): return tableView.selectedRowIndexes.count == 1
        case #selector(doRevealTarget): return tableView.selectedRowIndexes.count == 1
        case #selector(doTrash): return tableView.selectedRowIndexes.count > 0
        case #selector(doTrashTarget): return tableView.selectedRowIndexes.count > 0
        case #selector(doCopyAll): return tableView.numberOfRows > 0
        default: return true
        }
    }
}
