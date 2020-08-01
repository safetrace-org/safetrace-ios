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

    var traceIDs = Set<String>()
    var records: [PeripheralRecord]

    init?(records: [PeripheralRecord]) {
        if records.isEmpty {
            return nil
        }

        let sortedRecords = records.sorted(by: { $0.scanDate < $1.scanDate })
        let count = sortedRecords.count

        var totalRSSI: Int = 0
        var totalInterval: Double = 0
        var name: String?

        for (index, record) in sortedRecords.enumerated() {
            totalRSSI += record.rssi

            if let traceID = record.traceID {
                traceIDs.insert(traceID)
            }

            if
                name == nil,
                let peripheralName = record.name
            {
                name = peripheralName
            }

            if index >= 1 {
                let lastRecord = sortedRecords[index - 1]
                let scanInterval = record.scanDate.timeIntervalSince1970 - lastRecord.scanDate.timeIntervalSince1970
                totalInterval += scanInterval
            }
        }

        self.name = name
        self.count = count
        self.averageRSSI = totalRSSI / count
        self.averageDiscoveryInterval = count > 1
            ? totalInterval / Double(count - 1)
            : nil
        self.lastDiscoveryDate = sortedRecords.last!.scanDate

        let uploads = sortedRecords.filter { $0.traceUploadedDate != nil }

        self.lastUploadedDate = uploads.last?.traceUploadedDate
        self.skippedCount = sortedRecords.filter { $0.isSkipped }.count
        self.tracesCreated = sortedRecords.filter { $0.traceGeneratedDate != nil }.count
        self.tracesUploaded = uploads.count
        self.errorCount = sortedRecords.filter { $0.error != nil }.count
        self.phoneModel = sortedRecords.first(where: { $0.phoneModel != nil })?.phoneModel

        if let lastUploadedDate = lastUploadedDate, lastUploadedDate > lastDiscoveryDate {
            self.lastUpdatedDate = lastUploadedDate
        } else {
            self.lastUpdatedDate = lastDiscoveryDate
        }
        self.records = sortedRecords
    }
}

class PeripheralRecord {
    // Scan info
    var name: String?
    var uuid: UUID
    var rssi: Int
    var isSkipped: Bool
    var foreground: Bool
    var scanDate: Date

    // Trace info
    var traceID: String?
    var traceGeneratedDate: Date?
    var phoneModel: String?
    var senderForeground: Bool?

    // Upload info
    var traceUploadedDate: Date?

    // Error info
    var error: DebugTraceError?

    init(
        name: String?,
        uuid: UUID,
        rssi: Int,
        isSkipped: Bool,
        foreground: Bool,
        scanDate: Date
    ) {
        self.name = name
        self.uuid = uuid
        self.rssi = rssi
        self.isSkipped = isSkipped
        self.foreground = foreground
        self.scanDate = scanDate
    }

    func updateWithTrace(_ trace: DebugTrace) {
        traceID = trace.traceID
        traceGeneratedDate = trace.createdDate
        phoneModel = trace.phoneModel
        senderForeground = trace.senderForeground
    }

    func updateWithUpload(_ upload: DebugTraceUpload) {
        traceUploadedDate = upload.uploadedDate
    }

    func updateWithError(_ error: DebugTraceError) {
        self.error = error
    }
}

class BluetoothDebugViewController: UIViewController {

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    private let optionsViewHeight: CGFloat = 50

    private var debugPeripheralsByUUID = [UUID: [DebugDiscoveredPeripheral]]()
    private var debugTracesByUUID = [UUID: [DebugTrace]]()
    private var debugTraceUploadsByUUID = [UUID: [DebugTraceUpload]]()
    private var debugTraceErrorsByUUID = [UUID: [DebugTraceError]]()
    // For easily matching uploads to traces
    private var traceIDMap = [String: Set<DebugTrace>]()

    private var displayData = [PeripheralDevice]()

    private var shouldDeduplicate: Bool = false
    private var filterBackgroundOnly: Bool = false

    // MARK: - Views

    private let tableView = UITableView()


    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Bluetooth Debugger"
        navigationItem.leftBarButtonItem = .init(title: "Clear", style: .plain, target: self, action: #selector(clearRecords))
        navigationItem.rightBarButtonItem = .init(title: "Close", style: .done, target: self, action: #selector(dismissVC))

        layoutUI()
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

    private func layoutUI() {
        tableView.contentInset.top = optionsViewHeight
        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)

        let backgroundOnlySwitch = UISwitch()
        backgroundOnlySwitch.addTarget(self, action: #selector(backgroundOnlyToggled), for: .valueChanged)

        let backgroundOnlyLabel = UILabel()
        backgroundOnlyLabel.font = .bodyRegular
        backgroundOnlyLabel.text = "Background only"
        let backgroundOnlyStack = UIStackView(arrangedSubviews: [backgroundOnlyLabel, backgroundOnlySwitch])
        backgroundOnlyStack.distribution = .fillProportionally

        let deduplicateSwitch = UISwitch()
        deduplicateSwitch.addTarget(self, action: #selector(deduplicateToggled), for: .valueChanged)

        let dedupeLabel = UILabel()
        dedupeLabel.font = .bodyRegular
        dedupeLabel.text = "Dedupe"
        let deduplicateStack = UIStackView(arrangedSubviews: [dedupeLabel, deduplicateSwitch])
        deduplicateStack.distribution = .fillProportionally

        let optionsStack = UIStackView(arrangedSubviews: [backgroundOnlyStack, deduplicateStack])
        optionsStack.distribution = .fillEqually
        optionsStack.alignment = .center
        optionsStack.spacing = 10
        optionsStack.backgroundColor = .white

        let optionsView = UIView()
        if #available(iOS 13.0, *) {
            optionsView.backgroundColor = .systemBackground
        } else {
            optionsView.backgroundColor = .white
        }
        optionsView.addSubview(optionsStack)

        view.addSubview(optionsView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        optionsStack.translatesAutoresizingMaskIntoConstraints = false
        optionsView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            optionsStack.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor),
            optionsStack.topAnchor.constraint(equalTo: optionsView.topAnchor),
            optionsStack.trailingAnchor.constraint(equalTo: optionsView.trailingAnchor),
            optionsStack.bottomAnchor.constraint(equalTo: optionsView.bottomAnchor),

            optionsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            optionsView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            optionsView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            optionsView.heightAnchor.constraint(equalToConstant: optionsViewHeight)
        ])
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
        Debug.clearDebugTraceRecords()

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

    @objc private func backgroundOnlyToggled() {
        filterBackgroundOnly.toggle()
        processAndReloadData()
    }

    @objc private func deduplicateToggled() {
        shouldDeduplicate.toggle()
        processAndReloadData()
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
            let traceID = trace.traceID
            if var tracesForTraceID = traceIDMap[traceID] {
                tracesForTraceID.insert(trace)
                traceIDMap[traceID] = tracesForTraceID
            } else {
                traceIDMap[traceID] = Set<DebugTrace>([trace])
            }

            let uuid = trace.peripheralUUID
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
        for upload in uploads.sorted(by: { $0.createdDate < $1.createdDate }) {
            let id = upload.traceID
            if
                let uuidSet = traceIDMap[id],
                let matchingTrace = uuidSet.first(where: { upload.createdDate == $0.createdDate })
            {
                let uuid = matchingTrace.peripheralUUID
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

                var baseRecords = discoveries.map {
                    PeripheralRecord(
                        name: $0.peripheral.name,
                        uuid: uuid,
                        rssi: $0.rssi,
                        isSkipped: $0.isSkipped,
                        foreground: $0.foreground,
                        scanDate: $0.scanDate
                    )
                }

                if self.filterBackgroundOnly {
                    baseRecords = baseRecords.filter { !$0.foreground }
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
                            currentRecord.updateWithTrace(currentTrace)
                            traceIndex += 1
                        }
                    }

                    if let uploads = self.debugTraceUploadsByUUID[uuid], uploadIndex < uploads.count {
                        let currentUpload = uploads[uploadIndex]
                        if currentRecord.traceGeneratedDate == currentUpload.createdDate {
                            currentRecord.updateWithUpload(currentUpload)
                            uploadIndex += 1
                        }
                    }

                    if let errors = self.debugTraceErrorsByUUID[uuid], errorIndex < errors.count {
                        let currentError = errors[errorIndex]
                        let timestamp = currentError.createdDate

                        if let nextRecord = nextRecord, nextRecord.scanDate < timestamp {
                            // do not attribute error to this record
                        } else {
                            currentRecord.updateWithError(currentError)
                            errorIndex += 1
                        }
                    }

                    recordIndex += 1
                }

                if self.filterBackgroundOnly {
                    // Secondary filtering to make sure the sender was also in background
                    baseRecords = baseRecords.filter { $0.senderForeground == .some(false) }
                }

                if let peripheralDevice = PeripheralDevice(records: baseRecords) {
                    if !self.shouldDeduplicate {
                        self.displayData.append(peripheralDevice)
                    } else {
                        var combineIndex: Int? = nil
                        for (index, existingDevice) in self.displayData.enumerated() {
                            let sameName = existingDevice.name != nil && existingDevice.name == peripheralDevice.name
                            let samePhoneModel = existingDevice.phoneModel != nil && existingDevice.phoneModel == peripheralDevice.phoneModel
                            let overlappingTraceID = !existingDevice.traceIDs.intersection(peripheralDevice.traceIDs).isEmpty

                            let shouldCombine = sameName || samePhoneModel || overlappingTraceID
                            if shouldCombine {
                                combineIndex = index
                                break
                            }
                        }

                        if
                            let combineIndex = combineIndex,
                            let combinedPeripheralDevice = PeripheralDevice(records: self.displayData[combineIndex].records + peripheralDevice.records)
                        {
                            self.displayData[combineIndex] = combinedPeripheralDevice
                        } else {
                            self.displayData.append(peripheralDevice)
                        }
                    }
                }
            }

            self.displayData = self.displayData.sorted { $0.lastDiscoveryDate > $1.lastDiscoveryDate }
            self.tableView.reloadData()
        }
    }
}

extension BluetoothDebugViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let records = displayData[indexPath.row].records
        let detailVC = BluetoothDebugDetailViewController()
        detailVC.setRecords(records: records)

        navigationController?.pushViewController(detailVC, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let peripheral = displayData[indexPath.row]

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")

        var title = "\(indexPath.row + 1). " + (peripheral.name ?? "null")
        if let phoneModel = peripheral.phoneModel {
            title += " [\(phoneModel)]"
        }
        title += " (\(peripheral.count) / \(peripheral.tracesCreated) / \(peripheral.tracesUploaded) / \(peripheral.errorCount) / \(peripheral.skippedCount))"
        cell.textLabel?.text = title
        cell.textLabel?.numberOfLines = 0

        let displayInterval = peripheral.averageDiscoveryInterval != nil
            ? "\(Int(peripheral.averageDiscoveryInterval!))"
            : "n/a"
        let subtitle = "RSSI: \(Int(peripheral.averageRSSI)) | Interval: \(displayInterval) s | Updated: \(dateFormatter.string(from: peripheral.lastUpdatedDate))"
        cell.detailTextLabel?.text = subtitle
        cell.detailTextLabel?.numberOfLines = 0

        return cell
    }

}
