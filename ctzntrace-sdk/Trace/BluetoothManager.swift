import CoreBluetooth
import CoreLocation
import Foundation
import UIKit
import UserNotifications

// The data sent OTA between devices
private struct TracePacket: Codable {
    let traceID: String
    let foreground: Bool
    let phoneModel: String
}

// Traces are assembled from multiple separate async methods — this
// structure keeps them together until it's time to use them
private struct PendingTraceData {
    var rssi: NSNumber?
    var packet: TracePacket?
}

private let isEnabledDefaultsIdentifier = "org.ctzn.tracing_enabled"
private let pendingContactDefaultsIdentifier = "org.ctzn.pending_contacts"
private let debugNotifsDefaultsIdentifier = "org.ctzn.debug_notifications"
private let contactTracingServiceIdentifier = CBUUID(string: "0000cd19-0000-1000-8000-00805f9b34fb")
private let tracePacketCharacteristicIdentifier = CBUUID(string: "0000cd20-0000-1000-8000-00805f9b34fb")
private let centralRestorationIdentifier = "com.citizen.bluetoothRestoration.central"
private let peripheralRestorationIdentifier = "com.citizen.bluetoothRestoration.peripheral"

internal final class BluetoothManager: NSObject {
    private let environment: Environment
    private var peripheralManager: CBPeripheralManager?
    private var centralManager: CBCentralManager?
    private var characteristic: CBMutableCharacteristic?
    private var pendingTraceDataByPeripheralUUID: [UUID: PendingTraceData] = [:]
    private var connectedPeripherals: [CBPeripheral] = []
    private let uuidStorage: TraceIDStorage
    
    internal var debugNotificationsEnabled = false
    
    // Keep track of discovered android devices, so that we do not connect to the same Android device multiple times.
    // Our Android code sets a Manufacturer field for this purpose.
    private var discoveredAndroidManufacturerData = [Data]()

    var isBluetoothPermissionEnabled: Bool {
        if #available(iOS 13.1, *) {
            return CBCentralManager.authorization == .allowedAlways
        }
        return CBPeripheralManager.authorizationStatus() == .authorized
    }

    var isBluetoothPermissionDenied: Bool {
        if #available(iOS 13.1, *) {
            return CBCentralManager.authorization == .denied
        }
        return CBPeripheralManager.authorizationStatus() == .denied
    }

    var isTracingEnabled: Bool {
        return environment.defaults.bool(forKey: isEnabledDefaultsIdentifier)
    }

    var isTracingActive: Bool {
        return isTracingEnabled && isBluetoothPermissionEnabled
    }
    
    init(environment: Environment) {
        self.environment = environment
        self.uuidStorage = TraceIDStorage(environment: environment)
        self.debugNotificationsEnabled = environment.defaults.bool(forKey: debugNotifsDefaultsIdentifier)
    }
    
    func startScanning() {
        guard isTracingEnabled else { return }
        startCentralManager()
        startPeripheralManager()
    }
    
    func stopScanning() {
        peripheralManager?.removeAllServices()
        centralManager?.stopScan()
        peripheralManager = nil
        centralManager = nil
    }
    
    func optIn() {
        environment.defaults.set(true, forKey: isEnabledDefaultsIdentifier)
        startScanning()
    }

    func optOut() {
        environment.defaults.set(false, forKey: isEnabledDefaultsIdentifier)
        stopScanning()
    }
    
    func setDebugNotificationsEnabled(_ enabled: Bool) {
        environment.defaults.set(enabled, forKey: debugNotifsDefaultsIdentifier)
        self.debugNotificationsEnabled = enabled
        
        if enabled {
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound],
                completionHandler: { _, _ in })
        }
    }
    
    func reportPendingTraces() {
        let traces = loadPendingTraces()
        guard traces.count > 0 else { return }
        
        reportTraces(traces) {
            self.clearPendingTrace()
        }
    }
    
    func updateTraceIDsIfNeeded() {
        uuidStorage.updateStoredIDsIfNeeded()
    }
    
    func clearTraceIDs() {
        uuidStorage.clearStoredIDs()
    }

    // MARK: - Start Managaers
    private func startPeripheralManager() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [
            CBCentralManagerOptionRestoreIdentifierKey: peripheralRestorationIdentifier
        ])
    }
    
    private func startPeripheralService() {
        characteristic = CBMutableCharacteristic(
            type: tracePacketCharacteristicIdentifier,
            properties: [.read],
            value: nil,
            permissions: [.readable]
        )
        
        let serviceUUID = contactTracingServiceIdentifier
        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [characteristic!]
        peripheralManager?.removeAllServices()
        peripheralManager?.add(service)
    }
    
    private func startCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [
            CBCentralManagerOptionRestoreIdentifierKey: centralRestorationIdentifier,
            CBCentralManagerOptionShowPowerAlertKey: true
        ])
    }

    private func removeConnectedPeripheral(_ peripheral: CBPeripheral) {
        pendingTraceDataByPeripheralUUID.removeValue(forKey: peripheral.identifier)
        connectedPeripherals.removeAll(where: { $0 == peripheral })
    }
    
    // MARK: - Contact Reporting
    private func addReport(packet: TracePacket, rssi: NSNumber) {
        let trace = ContactTrace(
            tracePacket: packet,
            rssi: rssi,
            timestamp: Date(),
            location: nil, // todo
            foreground: environment.device.appState() == .active)
        
        if environment.device.appState() != .background {
            reportTraces([trace])
        } else {
            savePendingTrace(trace)
        }
    }
    
    private func reportTraces(_ traces: [ContactTrace], success: (() -> Void)? = nil) {
        guard let userID = environment.session.userID else { return }
        
        let traceData = ContactTraces(traces: traces, phoneModel: environment.device.model())
        
        environment.network.uploadTraces(traceData, userID: userID) { result in
            self.notifyTraceUpload(count: traces.count, error: result.error)
            success?()
        }
    }
    
    private func loadPendingTraces() -> [ContactTrace] {
        if let json = environment.defaults.data(forKey: pendingContactDefaultsIdentifier),
            let contacts = try? JSONDecoder().decode([ContactTrace].self, from: json) {
            
            return contacts
        }
        
        return []
    }
    
    private func savePendingTraces(_ contacts: [ContactTrace]) {
        guard let json = try? JSONEncoder().encode(contacts) else {
            assertionFailure("Could not serialize contacts")
            return
        }
        
        environment.defaults.set(json, forKey: pendingContactDefaultsIdentifier)
    }
    
    private func savePendingTrace(_ contact: ContactTrace) {
        let existingContacts = loadPendingTraces()
        savePendingTraces(existingContacts + [contact])
    }
    
    private func clearPendingTrace() {
        savePendingTraces([])
    }
    
    private func logError(_ errorString: String, context: String) {
        // todo
    }
}

// MARK: - CBPeripheralManagerDelegate
extension BluetoothManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            startPeripheralService()
        }
    }
    
    func peripheralManager(_ manager: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        manager.startAdvertising([
            CBAdvertisementDataLocalNameKey: "Contact Tracing Service",
            CBAdvertisementDataServiceUUIDsKey: [service.uuid]
        ])
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String: Any]) {
        // no-op
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        uuidStorage.getCurrentID { traceID in
            guard let traceID = traceID else {
                self.logError("UUID not found", context: "didReceiveReadRequest")
                peripheral.respond(to: request, withResult: .attributeNotFound)
                return
            }
            
            let packet = TracePacket(
                traceID: traceID,
                foreground: self.environment.device.appState() == .active,
                phoneModel: self.environment.device.model())
            
            let jsonData = try? JSONEncoder().encode(packet)
            request.value = jsonData
            peripheral.respond(to: request, withResult: .success)
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
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
extension BluetoothManager: CBPeripheralDelegate {
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
        if let packet = data.packet, let rssi = data.rssi {
            addReport(packet: packet, rssi: rssi)
            notifyPeripheralDiscovery(peripheral: peripheral, rssi: rssi, value: packet.description)
            removeConnectedPeripheral(peripheral)
        }
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

// MARK: - Debug
extension BluetoothManager {
    private func notifyPeripheralDiscovery(
        peripheral: CBPeripheral,
        rssi: NSNumber,
        value: String
    ) {
        guard debugNotificationsEnabled else { return }
        let content = UNMutableNotificationContent()
        
        var text = peripheral.name ?? "unknown"
        text += " @ RSSI = \(rssi)"

        content.title = "\(text)"
        content.body = value
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(identifier: "Bluetooth Discovery", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { _ in }
    }
        
    private func notifyPeripheralError(
        peripheral: CBPeripheral,
        context: String,
        error: Error?
    ) {
        guard debugNotificationsEnabled else { return }
        let content = UNMutableNotificationContent()
        
        let text = peripheral.name ?? "unknown"
        content.title = "ERROR: \(text)"
        content.body = "\(context) - \(error?.localizedDescription ?? "none")"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "Bluetooth Discovery", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { _ in }
    }
    
    private func notifyTraceUpload(
        count: Int,
        error: Error?
    ) {
        guard debugNotificationsEnabled else { return }
        let content = UNMutableNotificationContent()
        
        content.title = "UPLOADED \(count) TRACES"
        content.body = "Error: \(error?.localizedDescription ?? "none")"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(identifier: "Bluetooth Upload", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { _ in }
    }
}
