import SafeTrace
import UIKit

class HealthCheckDebugViewController: UITableViewController {

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()
    var healthChecks: [DebugHealthCheck] = []

    // MARK: - Views

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsSelection = false

        navigationItem.title = "Health Check Debugger"
        navigationItem.leftBarButtonItem = .init(title: "Clear", style: .plain, target: self, action: #selector(clearRecords))
        navigationItem.rightBarButtonItem = .init(title: "Close", style: .done, target: self, action: #selector(dismissVC))

        initialLoad()

        Debug.healthCheckHandler = { [weak self] healthCheck in
            self?.addHealthCheck(healthCheck)
            self?.reload()
        }
    }

    private func initialLoad() {
        healthChecks = Debug.healthChecks

        reload()
    }

    private func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    @objc private func clearRecords() {
        Debug.clearHealthCheckRecords()

        initialLoad()
    }

    @objc private func dismissVC() {
        self.dismiss(animated: true)
    }

    // MARK: - Helper Functions

    private func addHealthCheck(_ healthCheck: DebugHealthCheck) {
        if
            let lastTimestamp = healthChecks.last?.timestamp,
            healthCheck.timestamp > lastTimestamp
        {
            healthChecks.append(healthCheck)
        } else if let index = healthChecks.firstIndex(where: { $0.timestamp == healthCheck.timestamp }) {
            healthChecks[index] = healthCheck
        } else {
            healthChecks.append(healthCheck)
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        healthChecks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let healthCheck = healthChecks[indexPath.row]

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")

        let status: String
        switch healthCheck.succeeded {
        case .some(true):
            status = "sent"
        case .some(false):
            status = "failed"
        case .none:
            status = "sending..."
        }

        var title = "\(indexPath.row + 1). " + (healthCheck.wakeReason.rawValue)
        title += " " + dateFormatter.string(from: healthCheck.timestamp)
        title += " [\(status)]"
        cell.textLabel?.text = title
        cell.textLabel?.font = .bodyBold
        cell.textLabel?.numberOfLines = 0

        var subtitle = "BT: \(healthCheck.bluetoothEnabled) | Push: \(healthCheck.pushEnabled) | isOptedIn: \(healthCheck.isOptedIn) | BLE: \(healthCheck.bluetoothHardwareEnabled)"
        if let error = healthCheck.error {
            subtitle += " | Error: \(error)"
        }
        cell.detailTextLabel?.text = subtitle
        cell.detailTextLabel?.numberOfLines = 0

        return cell
    }

}
