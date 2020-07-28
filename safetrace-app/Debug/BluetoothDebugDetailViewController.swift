import UIKit

class BluetoothDebugDetailViewController: UITableViewController {
    private var records: [PeripheralRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(BluetoothDebugDetailCell.self, forCellReuseIdentifier: String(describing: BluetoothDebugDetailCell.self))
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }

    func setRecords(records: [PeripheralRecord]) {
        self.records = records
        reload()
    }

    func reload() {
        var name = records.first(where: { $0.name != nil })?.name ?? "null"
        if let phoneModel = records.first(where: { $0.phoneModel != nil })?.phoneModel {
            name += " [\(phoneModel)]"
        }
        navigationItem.title = name

        tableView.reloadData()
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = records[indexPath.row]
        UIPasteboard.general.string = record.traceID ?? "null"

        let alert = UIAlertController(title: "Trace ID Copied", message: nil, preferredStyle: .alert)
        present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        records.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let record = records[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BluetoothDebugDetailCell.self), for: indexPath) as! BluetoothDebugDetailCell
        cell.configure(record: record, index: indexPath.row)

        return cell
    }
}
