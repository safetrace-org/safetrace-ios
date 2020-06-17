import CoreBluetooth

struct BluetoothPermissions {
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
}
