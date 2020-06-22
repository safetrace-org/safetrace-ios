import Foundation

protocol Environment {
    var bluetoothPermissions: BluetoothPermissionsProviding { get }
    var notificationPermissions: NotificationPermissionsProviding { get }
    var safeTrace: SafeTraceProviding { get }
    var citizen: CitizenProviding { get }
}
