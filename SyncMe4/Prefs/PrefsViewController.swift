import AppKit

final class PrefsViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<PrefsAction>)?

    @IBOutlet var tableView: NSTableView!

    lazy var datasource: (any TableViewDatasourceType<PrefsEffect, PrefsState>) = PrefsDatasource(
        tableView: tableView,
        processor: processor
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await processor?.receive(.initialData)
        }
    }

    func present(_ state: PrefsState) async {
        await datasource.present(state)
    }

    func receive(_ effect: PrefsEffect) async {
        await datasource.receive(effect)
    }

    @IBAction func doAdd(_ sender: Any) {
        view.window?.endEditing(for: nil)
        Task {
            await processor?.receive(.add)
        }
    }

    @IBAction func doDelete(_ sender: Any) {
        let row = tableView.selectedRow
        guard row > -1 else {
            return
        }
        view.window?.endEditing(for: nil)
        Task {
            await processor?.receive(.delete(row: row))
        }
    }

    @IBAction func doCancel(_ sender: Any) {
        Task {
            await processor?.receive(.cancel)
        }
    }

    @IBAction func doSave(_ sender: Any) {
        view.window?.endEditing(for: nil)
        Task {
            await processor?.receive(.save)
        }
    }

    @objc func didEndEditing(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let text = sender.stringValue
        Task {
            await processor?.receive(.changed(row: row, text: text))
        }
    }

    deinit {
        print("farewell from prefs view controller")
    }

}
