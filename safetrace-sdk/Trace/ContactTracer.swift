import CoreBluetooth
import CoreLocation
import Foundation
import UIKit
import UserNotifications

public struct TraceError: Error {
    public let error: String
    public let context: String
}

// The data sent OTA between devices
internal struct TracePacket: Codable {
    let traceID: String
    let foreground: Bool
    let phoneModel: String
}

internal let isEnabledDefaultsIdentifier = "org.ctzn.tracing_enabled"
internal let pendingContactDefaultsIdentifier = "org.ctzn.pending_contacts"
internal let contactTracingServiceIdentifier = CBUUID(string: "0000cd19-0000-1000-8000-00805f9b34fb")
internal let tracePacketCharacteristicIdentifier = CBUUID(string: "0000cd20-0000-1000-8000-00805f9b34fb")
internal let centralRestorationIdentifier = "org.ctzn.bluetoothRestoration.central"
internal let peripheralRestorationIdentifier = "org.ctzn.bluetoothRestoration.peripheral"

internal final class ContactTracer: NSObject {
    var errorHandler: ((TraceError) -> Void)?
    
    private let environment: Environment
    private let peripheral: BluetoothPeripheral
    private let central: BluetoothCentral

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

    var isBluetoothHardwareEnabled: Bool {
        return central.centralManager?.state == .some(.poweredOn)
    }

    var isTracingEnabled: Bool {
        return environment.defaults.bool(forKey: isEnabledDefaultsIdentifier)
    }

    var isTracingActive: Bool {
        return isTracingEnabled && isBluetoothPermissionEnabled
    }
    
    init(environment: Environment) {
        self.environment = environment
        self.peripheral = BluetoothPeripheral(environment: environment)
        self.central = BluetoothCentral(environment: environment)
        super.init()
        self.central.delegate = self
        self.peripheral.delegate = self
    }
    
    func startScanning() {
        guard isTracingEnabled else { return }
        peripheral.start()
        central.start()
    }
    
    func stopScanning() {
        peripheral.stop()
        central.stop()
    }
    
    func optIn() {
        environment.defaults.set(true, forKey: isEnabledDefaultsIdentifier)
        startScanning()
    }

    func optOut() {
        environment.defaults.set(false, forKey: isEnabledDefaultsIdentifier)
        stopScanning()
    }
    
    func reportPendingTraces() {
        let traces = loadPendingTraces()
        guard traces.count > 0 else { return }
        
        reportTraces(traces) {
            self.clearPendingTrace()
        }
    }
    
    func logError(_ error: String, context: String) {
        errorHandler?(TraceError(error: error, context: context))
    }

    // MARK: - Contact Reporting
    private func addTrace(_ trace: ContactTrace) {
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
            Debug.notify(
                title: "UPLOADED \(traces.count) TRACES",
                body: "Error: \(result.error?.localizedDescription ?? "none")",
                identifier: "bt_upload")
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
}

extension ContactTracer: BluetoothCentralDelegate {
    func didFinishTrace(_ trace: ContactTrace) {
        addTrace(trace)
    }
}

extension ContactTracer: BluetoothPeripheralDelegate { }
