import CoreBluetooth
import SafeTrace
import UIKit

struct PeripheralDevice {
    var name: String?
    var count: Int
    var averageRSSI: Int
    var averageDiscoveryInterval: Double?
    var lastDiscoveryDate: Date
    var skippedCount: Int
    var tracesCreated: Int
    var tracesUploaded: Int
    var errorCount: Int
    var phoneModel: String?
    var lastUploadedDate: Date?
    var lastUpdatedDate: Date

    init(records: [PeripheralRecord]) {
        if records.isEmpty {
            assertionFailure("records cannot be empty")
        }

        let count = records.count

        var totalRSSI: Int = 0
        var totalInterval: Double = 0
        var name: String?

        for (index, record) in records.enumerated() {
            totalRSSI += record.rssi

            if
                name == nil,
                let peripheralName = record.name
            {
                name = peripheralName
            }

            if index >= 1 {
                let lastRecord = records[index - 1]
                let scanInterval = record.scanDate.timeIntervalSince1970 - lastRecord.scanDate.timeIntervalSince1970
                totalInterval += scanInterval
            }
        }

        self.name = name
        self.count = count
        self.averageRSSI = count > 0
            ? totalRSSI / count
            : 0
        self.averageDiscoveryInterval = count > 1
            ? totalInterval / Double(count - 1)
            : nil
        self.lastDiscoveryDate = records.last!.scanDate

        let uploads = records.filter { $0.traceUploadedDate != nil }

        self.lastUploadedDate = uploads.last?.traceUploadedDate
        self.skippedCount = records.filter { $0.isSkipped }.count
        self.tracesCreated = records.filter { $0.traceGeneratedDate != nil }.count
        self.tracesUploaded = uploads.count
        self.errorCount = records.filter { $0.error != nil }.count
        self.phoneModel = records.first(where: { $0.phoneModel != nil })?.phoneModel

        if let lastUploadedDate = lastUploadedDate, lastUploadedDate > lastDiscoveryDate {
            self.lastUpdatedDate = lastUploadedDate
        } else {
            self.lastUpdatedDate = lastDiscoveryDate
        }
    }
}

class PeripheralRecord {
    // Scan info
    var name: String?
    var rssi: Int
    var isSkipped: Bool
    var foreground: Bool
    var scanDate: Date

    // Trace info
    var traceGeneratedDate: Date?
    var phoneModel: String?

    // Upload info
    var traceUploadedDate: Date?

    // Error info
    var error: DebugTraceError?

    init(
        name: String?,
        rssi: Int,
        isSkipped: Bool,
        foreground: Bool,
        scanDate: Date
    ) {
        self.name = name
        self.rssi = rssi
        self.isSkipped = isSkipped
        self.foreground = foreground
        self.scanDate = scanDate
    }
}

class BluetoothDebugViewController: UITableViewController {

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    private var debugPeripheralsByUUID = [UUID: [DebugDiscoveredPeripheral]]()
    private var debugTracesByUUID = [UUID: [DebugTrace]]()
    private var debugTraceUploadsByUUID = [UUID: [DebugTraceUpload]]()
    private var debugTraceErrorsByUUID = [UUID: [DebugTraceError]]()

    private var traceIDMap = [String: UUID]()

    private var displayData = [PeripheralDevice]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Bluetooth Debugger"
        navigationItem.leftBarButtonItem = .init(title: "Clear", style: .plain, target: self, action: #selector(clearRecords))
        navigationItem.rightBarButtonItem = .init(title: "Close", style: .done, target: self, action: #selector(dismissVC))

        initialLoad()

        Debug.debugPeripheralHandler = { [weak self] discovery in
            self?.addPeripheralDiscoveries([discovery])
            self?.processAndReloadData()
        }
        Debug.debugTraceHandler = {[weak self] trace in
            self?.addTraces([trace])
            self?.processAndReloadData()
        }
        Debug.traceErrorHandler = { [weak self] error in
            self?.addTraceErrors([error])
            self?.processAndReloadData()
        }
        Debug.tracesUploadedHandler = { [weak self] uploads in
            self?.addTraceUploads(uploads)
            self?.processAndReloadData()
        }
    }

    private func initialLoad() {
        // Import existing traces
        addPeripheralDiscoveries(Debug.debugPeripherals)
        addTraces(Debug.debugTraces)
        addTraceErrors(Debug.traceErrors)
        addTraceUploads(Debug.traceUploads)

        processAndReloadData()
    }

    @objc private func clearRecords() {
        Debug.clearDebugRecords()

        debugPeripheralsByUUID = [:]
        debugTracesByUUID = [:]
        debugTraceUploadsByUUID = [:]
        debugTraceErrorsByUUID = [:]
        traceIDMap = [:]

        initialLoad()
    }

    @objc private func dismissVC() {
        self.dismiss(animated: true)
    }

    // MARK: - Helper functions

    private func addPeripheralDiscoveries(_ discoveries: [DebugDiscoveredPeripheral]) {
        discoveries.forEach { discovery in
            let uuid = discovery.peripheral.identifier
            if var discoveriesForDevice = debugPeripheralsByUUID[uuid] {
                discoveriesForDevice.append(discovery)
                debugPeripheralsByUUID[uuid] = discoveriesForDevice
            } else {
                debugPeripheralsByUUID[uuid] = [discovery]
            }
        }
    }

    private func addTraces(_ traces: [DebugTrace]) {
        traces.forEach { trace in
            let uuid = trace.peripheralUUID
            traceIDMap[trace.traceID] = uuid
            if var tracesForDevice = debugTracesByUUID[uuid] {
                tracesForDevice.append(trace)
                debugTracesByUUID[uuid] = tracesForDevice
            } else {
                debugTracesByUUID[uuid] = [trace]
            }
        }
    }

    private func addTraceErrors(_ errors: [DebugTraceError]) {
        errors.forEach { error in
            let uuid = error.peripheralUUID
            if var errorsForDevice = debugTraceErrorsByUUID[uuid] {
                errorsForDevice.append(error)
                debugTraceErrorsByUUID[uuid] = errorsForDevice
            } else {
                debugTraceErrorsByUUID[uuid] = [error]
            }
        }
    }

    private func addTraceUploads(_ uploads: [DebugTraceUpload]) {
        for upload in uploads {
            let id = upload.traceID
            if let uuid = traceIDMap[id] {
                if var uploadsForDevice = debugTraceUploadsByUUID[uuid] {
                    uploadsForDevice.append(upload)
                    debugTraceUploadsByUUID[uuid] = uploadsForDevice
                } else {
                    debugTraceUploadsByUUID[uuid] = [upload]
                }
            } else {
                print("ERROR: Could not find matching trace for upload")
            }
        }
    }

    private func processAndReloadData() {
        DispatchQueue.main.async {
            self.displayData = []
            for (uuid, discoveries) in self.debugPeripheralsByUUID {

                let baseRecords = discoveries.map {
                    PeripheralRecord(
                        name: $0.peripheral.name,
                        rssi: $0.rssi,
                        isSkipped: $0.isSkipped,
                        foreground: $0.foreground,
                        scanDate: $0.scanDate
                    )
                }

                // Hydrate discoveries

                var recordIndex = 0
                var traceIndex = 0
                var errorIndex = 0
                var uploadIndex = 0

                while recordIndex < baseRecords.count {
                    let currentRecord = baseRecords[recordIndex]
                    let nextRecord = recordIndex < baseRecords.count - 1
                        ? baseRecords[recordIndex + 1]
                        : nil

                    if let traces = self.debugTracesByUUID[uuid], traceIndex < traces.count {
                        let currentTrace = traces[traceIndex]
                        let timestamp = currentTrace.createdDate

                        if let nextRecord = nextRecord, nextRecord.scanDate < timestamp {
                            // do not attribute trace to this record
                        } else {
                            currentRecord.traceGeneratedDate = currentTrace.createdDate
                            currentRecord.phoneModel = currentTrace.phoneModel
                            traceIndex += 1
                        }
                    }

                    if let uploads = self.debugTraceUploadsByUUID[uuid], uploadIndex < uploads.count {
                        let currentUpload = uploads[uploadIndex]
                        if currentRecord.traceGeneratedDate == currentUpload.createdDate {
                            currentRecord.traceUploadedDate = currentUpload.uploadedDate
                            uploadIndex += 1
                        }
                    }

                    if let errors = self.debugTraceErrorsByUUID[uuid], errorIndex < errors.count {
                        let currentError = errors[errorIndex]
                        let timestamp = currentError.createdDate

                        if let nextRecord = nextRecord, nextRecord.scanDate < timestamp {
                            // do not attribute error to this record
                        } else {
                            currentRecord.error = currentError
                            errorIndex += 1
                        }
                    }

                    recordIndex += 1
                }

                let peripheralDevice = PeripheralDevice(records: baseRecords)
                self.displayData.append(peripheralDevice)
            }
            self.displayData = self.displayData.sorted { $0.lastDiscoveryDate > $1.lastDiscoveryDate }
            self.tableView.reloadData()
        }
    }
}

extension BluetoothDebugViewController {

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let peripheral = displayData[indexPath.row]

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")

        var title = peripheral.name ?? "null"
        if let phoneModel = peripheral.phoneModel {
            title += " [\(phoneModel)]"
        }
        title += " (\(peripheral.count) / \(peripheral.tracesCreated) / \(peripheral.tracesUploaded) / \(peripheral.errorCount) / \(peripheral.skippedCount))"
        cell.textLabel?.text = title

        let displayInterval = peripheral.averageDiscoveryInterval != nil
            ? "\(Int(peripheral.averageDiscoveryInterval!))"
            : "n/a"
        let subtitle = "RSSI: \(Int(peripheral.averageRSSI)) | Interval: \(displayInterval) s | Updated: \(dateFormatter.string(from: peripheral.lastUpdatedDate))"
        cell.detailTextLabel?.text = subtitle

        return cell
    }

}
