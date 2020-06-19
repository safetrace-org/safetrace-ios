import CoreBluetooth
import UIKit

struct BluetoothPermissions {
    static var centralManager: CBCentralManager?

    enum BluetoothAuthorization {
        case notDetermined
        case enabled
        case denied
    }

    static var currentAuthorization: BluetoothAuthorization {
        if BluetoothPermissions.isNotDetermined {
            return .notDetermined
        } else if BluetoothPermissions.isEnabled {
            return .enabled
        } else {
            return .denied
        }
    }

    static var isEnabled: Bool {
        if #available(iOS 13.1, *) {
            return CBCentralManager.authorization == .allowedAlways
        }
        return CBPeripheralManager.authorizationStatus() == .authorized
    }

    static var isDenied: Bool {
        if #available(iOS 13.1, *) {
            return CBCentralManager.authorization == .denied
        }
        return CBPeripheralManager.authorizationStatus() == .denied
    }

    static var isNotDetermined: Bool {
        if #available(iOS 13.1, *) {
            return CBCentralManager.authorization == .notDetermined
        }
        return CBPeripheralManager.authorizationStatus() == .notDetermined
    }

    static func requestPermissions() {
        // Initializing CBCentralManager prompts for bluetooth permissions
        centralManager = CBCentralManager()
        DispatchQueue(label: "bluetoothPermissions").asyncAfter(deadline: .now() + 3) {
            centralManager = nil
        }
    }

    static func openSettings() {
        guard
            let settingsUrl = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl)
        else {
            return
        }

        UIApplication.shared.open(settingsUrl, completionHandler: nil)
    }
}
