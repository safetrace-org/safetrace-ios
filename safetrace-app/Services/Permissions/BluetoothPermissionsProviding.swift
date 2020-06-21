import CoreBluetooth
import UIKit

enum BluetoothAuthorization {
    case notDetermined
    case enabled
    case denied
}

protocol BluetoothPermissionsProviding {
    var currentAuthorization: BluetoothAuthorization { get }
    func requestPermissions()
    func openSettings()
}

struct BluetoothPermissionsProvider: BluetoothPermissionsProviding {
    static var centralManager: CBCentralManager?

    var currentAuthorization: BluetoothAuthorization {
        if isNotDetermined {
            return .notDetermined
        } else if isEnabled {
            return .enabled
        } else {
            return .denied
        }
    }

    private var isEnabled: Bool {
        if #available(iOS 13.1, *) {
            return CBCentralManager.authorization == .allowedAlways
        }
        return CBPeripheralManager.authorizationStatus() == .authorized
    }

    private var isDenied: Bool {
        if #available(iOS 13.1, *) {
            return CBCentralManager.authorization == .denied
        }
        return CBPeripheralManager.authorizationStatus() == .denied
    }

    private var isNotDetermined: Bool {
        if #available(iOS 13.1, *) {
            return CBCentralManager.authorization == .notDetermined
        }
        return CBPeripheralManager.authorizationStatus() == .notDetermined
    }

    func requestPermissions() {
        // Initializing CBCentralManager prompts for bluetooth permissions
        BluetoothPermissionsProvider.centralManager = CBCentralManager()
        DispatchQueue(label: "bluetoothPermissions").asyncAfter(deadline: .now() + 3) {
            BluetoothPermissionsProvider.centralManager = nil
        }
    }

    func openSettings() {
        guard
            let settingsUrl = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl)
        else {
            return
        }

        UIApplication.shared.open(settingsUrl, completionHandler: nil)
    }
}
