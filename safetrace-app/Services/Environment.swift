import Foundation

protocol Environment {
    var bluetoothPermissions: BluetoothPermissionsProviding { get }
    var notificationPermissions: NotificationPermissionsProviding { get }
    var location: LocationProviding { get }
    var analytics: AnalyticsTracking { get }
    var safeTrace: SafeTraceProviding { get }
    var citizen: CitizenProviding { get }
}
