import CoreBluetooth
import Foundation
import CoreLocation

//sourcery:AutoMockable
protocol BluetoothCentralDelegate: AnyObject {
    func didFinishTrace(_ trace: ContactTrace)
    func logError(_: String, context _: String)
}

// Traces are assembled from multiple separate async methods — this
// structure keeps them together until it's time to use them
private struct PendingTraceData {
    var rssi: NSNumber?
    var packet: TracePacket?
}

internal final class BluetoothCentral: NSObject {
    weak var delegate: BluetoothCentralDelegate?
    var centralManager: CBCentralManager?

    private let environment: Environment
    private var connectedPeripherals: [CBPeripheral] = []
    private var pendingTraceDataByPeripheralUUID: [UUID: PendingTraceData] = [:]
    private let centralManagerClass: CBCentralManager.Type
    
    // Keep track of discovered android devices, so that we do not connect to the same Android device multiple times.
    // Our Android code sets a Manufacturer field for this purpose.
    private var discoveredAndroidManufacturerData = [Data]()

    var isStarted: Bool {
        return centralManager != nil
    }
    
    init(
        environment: Environment,
        centralManagerClass: CBCentralManager.Type = CBCentralManager.self
    ) {
        self.environment = environment
        self.centralManagerClass = centralManagerClass
    }
    
    func start() {
        guard !isStarted else { return }
        centralManager = centralManagerClass.init(delegate: self, queue: nil, options: [
            CBCentralManagerOptionRestoreIdentifierKey: centralRestorationIdentifier,
            CBCentralManagerOptionShowPowerAlertKey: true
        ])
    }
    
    func stop() {
        centralManager?.stopScan()
        centralManager = nil
    }
    
    private func logError(_ error: String, context: String) {
        delegate?.logError(error, context: context)
    }
    
    private func removeConnectedPeripheral(_ peripheral: CBPeripheral) {
        pendingTraceDataByPeripheralUUID.removeValue(forKey: peripheral.identifier)
        connectedPeripherals.removeAll(where: { $0 == peripheral })
        if peripheral.state == .connected || peripheral.state == .connecting {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothCentral: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ manager: CBCentralManager) {
        if manager.state == .poweredOn {
            let servicesToScan: [CBUUID]? = [contactTracingServiceIdentifier]
            centralManager?.scanForPeripherals(withServices: servicesToScan, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        // no-op
    }

    func centralManager(_ manager: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard !connectedPeripherals.contains(peripheral) else { return }
        
        if let manufacturer = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            let androidIdentifierData = manufacturer.subdata(in: 2..<manufacturer.count)
            if discoveredAndroidManufacturerData.contains(androidIdentifierData) {
                // Android device has already been discovered
                return
            } else {
                peripheral.delegate = self
                discoveredAndroidManufacturerData.append(androidIdentifierData)
                
                if discoveredAndroidManufacturerData.count > 100 {
                    discoveredAndroidManufacturerData.removeFirst()
                }
                
                connect(to: peripheral, rssi: RSSI)
            }
        } else {
            connect(to: peripheral, rssi: RSSI)
        }
    }

    private func connect(to peripheral: CBPeripheral, rssi: NSNumber) {
        peripheral.delegate = self
        centralManager?.connect(peripheral, options: nil)
        connectedPeripherals.append(peripheral)
        processRSSI(rssi, for: peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([contactTracingServiceIdentifier])
        peripheral.readRSSI()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        notifyPeripheralError(peripheral: peripheral, context: "didFailToConnect", error: error)
        logError(error?.localizedDescription ?? "none", context: "didFailToConnect")
        removeConnectedPeripheral(peripheral)
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothCentral: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            notifyPeripheralError(peripheral: peripheral, context: "didDiscoverServices", error: error)
            logError(error.localizedDescription, context: "didDiscoverServices")
            removeConnectedPeripheral(peripheral)
        } else if let service = peripheral.services?.first(where: { $0.uuid == contactTracingServiceIdentifier }) {
            peripheral.discoverCharacteristics([tracePacketCharacteristicIdentifier], for: service)
        } else {
            notifyPeripheralError(peripheral: peripheral, context: "didDiscoverServices", error: error)
            logError("Service Not Found", context: "didDiscoverServices")
            removeConnectedPeripheral(peripheral)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            notifyPeripheralError(peripheral: peripheral, context: "didDiscoverCharacteristics", error: error)
            logError(error.localizedDescription, context: "didDiscoverCharacteristics")
            removeConnectedPeripheral(peripheral)
        } else if let characteristic = service.characteristics?.first(where: { $0.uuid == tracePacketCharacteristicIdentifier }) {
            peripheral.readValue(for: characteristic)
        } else {
            notifyPeripheralError(peripheral: peripheral, context: "didDiscoverCharacteristics", error: nil)
            logError("Characteristic Not Found", context: "didDiscoverCharacteristics")
            removeConnectedPeripheral(peripheral)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            notifyPeripheralError(peripheral: peripheral, context: "didUpdateValue", error: error)
            logError(error.localizedDescription, context: "didUpdateValue")
            removeConnectedPeripheral(peripheral)
        } else if let data = characteristic.value {
            do {
                let packet = try JSONDecoder().decode(TracePacket.self, from: data)
                processPacket(packet, for: peripheral)
            } catch let error {
                notifyPeripheralError(peripheral: peripheral, context: "didUpdateValue", error: error)
                logError(error.localizedDescription, context: "didUpdateValue")
                removeConnectedPeripheral(peripheral)
            }
        } else {
            notifyPeripheralError(peripheral: peripheral, context: "didUpdateValue", error: nil)
            logError("No Value Sent", context: "didUpdateValue")
            removeConnectedPeripheral(peripheral)
        }
    }
    
    private func processPacket(_ packet: TracePacket, for peripheral: CBPeripheral) {
        if var data = pendingTraceDataByPeripheralUUID[peripheral.identifier] {
            data.packet = packet
            pendingTraceDataByPeripheralUUID[peripheral.identifier] = data
            finalizeTrace(data, peripheral: peripheral)
        } else {
            let data = PendingTraceData(rssi: nil, packet: packet)
            pendingTraceDataByPeripheralUUID[peripheral.identifier] = data
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if let error = error {
            notifyPeripheralError(peripheral: peripheral, context: "didReadRSSI", error: error)
            logError(error.localizedDescription, context: "didReadRSSI")
            removeConnectedPeripheral(peripheral)
        } else {
            processRSSI(RSSI, for: peripheral)
        }
    }
    
    func processRSSI(_ rssi: NSNumber, for peripheral: CBPeripheral) {
        if var data = pendingTraceDataByPeripheralUUID[peripheral.identifier] {
            data.rssi = rssi
            pendingTraceDataByPeripheralUUID[peripheral.identifier] = data
            finalizeTrace(data, peripheral: peripheral)
        } else {
            let data = PendingTraceData(rssi: rssi, packet: nil)
            pendingTraceDataByPeripheralUUID[peripheral.identifier] = data
        }
    }
    
    private func finalizeTrace(_ data: PendingTraceData, peripheral: CBPeripheral) {
        guard let packet = data.packet, let rssi = data.rssi else { return }
    
        let trace = ContactTrace(
            tracePacket: packet,
            rssi: rssi,
            timestamp: environment.date(),
            location: environment.location.current,
            foreground: environment.device.appState() == .active)

        delegate?.didFinishTrace(trace)
        notifyPeripheralDiscovery(peripheral: peripheral, rssi: rssi, value: packet.description)
        removeConnectedPeripheral(peripheral)
    }
}

// MARK: - Packet Construction
extension TracePacket: CustomStringConvertible {
    var description: String {
        "traceID: \(traceID)"
    }
}

private extension ContactTrace {
    init(tracePacket: TracePacket, rssi: NSNumber, timestamp: Date, location: CLLocation?, foreground: Bool) {
        let sender = Sender(
            foreground: tracePacket.foreground,
            signalStrength: rssi.doubleValue,
            phoneModel: tracePacket.phoneModel,
            traceID: tracePacket.traceID)
        
        let receiver = Receiver(
            timestamp: timestamp,
            location: Location(location),
            foreground: foreground)
        
        self.init(sender: sender, receiver: receiver)
    }
}

extension BluetoothCentral {
    private func notifyPeripheralError(
        peripheral: CBPeripheral,
        context: String,
        error: Error?
    ) {
        Debug.notify(
            title: "ERROR: \(peripheral.name ?? "unknown")",
            body: "\(context) - \(error?.localizedDescription ?? "none")",
            identifier: "bt_discovery")
    }
    
    private func notifyPeripheralDiscovery(
        peripheral: CBPeripheral,
        rssi: NSNumber,
        value: String
    ) {
        Debug.notify(
            title: "\(peripheral.name ?? "unknown") @ RSSI = \(rssi)",
            body: value,
            identifier: "bt_discovery")
    }
}
