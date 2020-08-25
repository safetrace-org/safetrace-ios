import Foundation

struct AppEnvironment: Environment {
    var bluetoothPermissions: BluetoothPermissionsProviding = BluetoothPermissionsProvider()
    var notificationPermissions: NotificationPermissionsProviding = NotificationPermissionsProvider()
    var safeTrace: SafeTraceProviding = SafeTraceProvider()
    var citizen: CitizenProviding = CitizenProvider()
    var analytics: AnalyticsTracking = AnalyticsTracker()

    init() {
        if Bundle.main.bundleIdentifier == "org.ctzn.safetrace-dev" {
            safeTrace.apiEnvironment = .staging
        } else {
            safeTrace.apiEnvironment = .production
        }
    }
}
