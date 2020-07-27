import CoreBluetooth
import Foundation
import UIKit
import UserNotifications

internal let debugNotifsDefaultsIdentifier = "org.ctzn.debug_notifications"
private var debugNotificationsEnabled = UserDefaults.standard.bool(forKey: debugNotifsDefaultsIdentifier)

private let peripheralDiscoveriesIdentifier = "org.ctzn.debug_discoveries"
private let debugTracesIdentifier = "org.ctzn.debug_traces"
private let debugTraceUploadsIdentifier = "org.ctzn.debug_trace_uploads"
private let debugTraceErrorsIdentifier = "org.ctzn.debug_trace_errors"

public struct DebugPeripheral: Codable {
    public var identifier: UUID
    public var name: String?

    init(peripheral: CBPeripheral) {
        self.identifier = peripheral.identifier
        self.name = peripheral.name
    }
}

public struct DebugDiscoveredPeripheral: Codable {
    public var peripheral: DebugPeripheral
    public var rssi: Int
    public var nameCharacteristic: String?
    public var uuidCharacteristic: [String]?
    public var isSkipped: Bool
    public var foreground: Bool
    public var scanDate: Date
}

public struct DebugTrace: Codable {
    public var peripheralUUID: UUID
    public var traceID: String
    public var senderForeground: Bool
    public var phoneModel: String
    public var createdDate: Date
}

public struct DebugTraceError: Codable {
    public var peripheralUUID: UUID
    public var description: String
    public var context: String
    public var createdDate: Date
}

public struct DebugTraceUpload: Codable {
    public var traceID: String
    public var createdDate: Date
    public var uploadedDate: Date
}

public enum Debug {

    public static var debugPeripherals: [DebugDiscoveredPeripheral] = loadDiscoveredPeripherals()
    public static var debugPeripheralHandler: ((DebugDiscoveredPeripheral) -> Void)?

    public static var debugTraces: [DebugTrace] = loadDebugTraces()
    public static var debugTraceHandler: ((DebugTrace) -> Void)?

    public static var traceUploads: [DebugTraceUpload] = loadTraceUploads()
    public static var tracesUploadedHandler: (([DebugTraceUpload]) -> Void)?

    public static var traceErrors: [DebugTraceError] = loadTraceErrors()
    public static var traceErrorHandler: ((DebugTraceError) -> Void)?


    // MARK: Clear Debug Records

    public static func clearDebugRecords() {
        #if INTERNAL
        debugPeripherals = []
        debugTraces = []
        traceUploads = []
        traceErrors = []

        saveDiscoveredPeripherals([])
        saveDebugTraces([])
        saveTracesUploads([])
        saveTracesErrors([])
        #endif
    }

    // MARK: Notifications

    static var notificationsEnabled: Bool {
        get {
            return debugNotificationsEnabled
        }
        set {
            debugNotificationsEnabled = newValue
            UserDefaults.standard.set(newValue, forKey: debugNotifsDefaultsIdentifier)
        }
    }
    
    static func notify(
        title: String,
        body: String,
        identifier: String
    ) {
        guard notificationsEnabled else { return }
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { _ in }
    }

    // MARK: - Debugger Peripheral Discovery

    static func recordPeripheralDiscovery(_ peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber, isSkipped: Bool) {
        #if INTERNAL
        let nameCharacteristic = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        let uuidCharacteristic = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID])?.map { $0.uuidString }

        let peripheralDiscovery = DebugDiscoveredPeripheral(
            peripheral: .init(peripheral: peripheral),
            rssi: RSSI.intValue,
            nameCharacteristic: nameCharacteristic,
            uuidCharacteristic: uuidCharacteristic,
            isSkipped: isSkipped,
            foreground: UIApplication.shared.applicationState == .active,
            scanDate: Date()
        )

        debugPeripherals.append(peripheralDiscovery)
        debugPeripheralHandler?(peripheralDiscovery)

        saveDiscoveredPeripherals(debugPeripherals)
        #endif
    }

    private static func saveDiscoveredPeripherals(_ data: [DebugDiscoveredPeripheral]) {
        guard let json = try? JSONEncoder().encode(data) else {
            assertionFailure("Could not serialize debug peripheral data")
            return
        }

        UserDefaults.standard.set(json, forKey: peripheralDiscoveriesIdentifier)
    }

    private static func loadDiscoveredPeripherals() -> [DebugDiscoveredPeripheral] {
        if let json = UserDefaults.standard.data(forKey: peripheralDiscoveriesIdentifier),
            let discoveries = try? JSONDecoder().decode([DebugDiscoveredPeripheral].self, from: json) {

            return discoveries
        }

        return []
    }

    // MARK: Debugger Trace Creation

    static func recordTraceCreation(_ packet: TracePacket, peripheral: CBPeripheral, timestamp: Date) {
        #if INTERNAL
        let trace = DebugTrace(
            peripheralUUID: peripheral.identifier,
            traceID: packet.traceID,
            senderForeground: packet.foreground,
            phoneModel: packet.phoneModel,
            createdDate: timestamp
        )

        debugTraces.append(trace)
        debugTraceHandler?(trace)

        saveDebugTraces(debugTraces)
        #endif
    }

    private static func saveDebugTraces(_ data: [DebugTrace]) {
        guard let json = try? JSONEncoder().encode(data) else {
            assertionFailure("Could not serialize debug trace")
            return
        }

        UserDefaults.standard.set(json, forKey: debugTracesIdentifier)
    }

    private static func loadDebugTraces() -> [DebugTrace] {
        if let json = UserDefaults.standard.data(forKey: debugTracesIdentifier),
            let traces = try? JSONDecoder().decode([DebugTrace].self, from: json) {

            return traces
        }

        return []
    }

    // MARK: Debugger Trace Uploads

    static func recordTraceUploads(_ traces: [ContactTrace]) {
        #if INTERNAL
        let uploadedDate = Date()

        let uploads = traces.map {
            DebugTraceUpload(
                traceID: $0.sender.traceID,
                createdDate: $0.receiver.timestamp,
                uploadedDate: uploadedDate
            )
        }

        traceUploads.append(contentsOf: uploads)
        tracesUploadedHandler?(uploads)

        saveTracesUploads(traceUploads)
        #endif
    }

    private static func saveTracesUploads(_ data: [DebugTraceUpload]) {
        guard let json = try? JSONEncoder().encode(data) else {
            assertionFailure("Could not serialize debug trace uploads")
            return
        }

        UserDefaults.standard.set(json, forKey: debugTraceUploadsIdentifier)
    }

    private static func loadTraceUploads() -> [DebugTraceUpload] {
        if let json = UserDefaults.standard.data(forKey: debugTraceUploadsIdentifier),
            let uploads = try? JSONDecoder().decode([DebugTraceUpload].self, from: json) {

            return uploads
        }

        return []
    }

    // MARK: Debugger Trace Errors

    static func recordTraceError(_ error: String, context: String, peripheral: CBPeripheral) {
        #if INTERNAL
        let error = DebugTraceError(
            peripheralUUID: peripheral.identifier,
            description: error,
            context: context,
            createdDate: Date()
        )

        traceErrors.append(error)
        traceErrorHandler?(error)

        saveTracesErrors(traceErrors)
        #endif
    }

    private static func saveTracesErrors(_ data: [DebugTraceError]) {
        guard let json = try? JSONEncoder().encode(data) else {
            assertionFailure("Could not serialize debug trace error")
            return
        }

        UserDefaults.standard.set(json, forKey: debugTraceErrorsIdentifier)
    }

    private static func loadTraceErrors() -> [DebugTraceError] {
        if let json = UserDefaults.standard.data(forKey: debugTraceErrorsIdentifier),
            let errors = try? JSONDecoder().decode([DebugTraceError].self, from: json) {

            return errors
        }

        return []
    }

    // MARK: - Record being read from another device

    static func recordDebugPeripheralReadRequest() {
        // TODO
    }
}
