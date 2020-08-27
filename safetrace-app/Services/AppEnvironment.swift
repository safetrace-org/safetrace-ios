import Foundation

struct AppEnvironment: Environment {
    var bluetoothPermissions: BluetoothPermissionsProviding = BluetoothPermissionsProvider()
    var notificationPermissions: NotificationPermissionsProviding = NotificationPermissionsProvider()
    var safeTrace: SafeTraceProviding = SafeTraceProvider()
    var citizen: CitizenProviding = CitizenProvider()
    var analytics: AnalyticsTracking = AnalyticsTracker()

    init() {
        #if INTERNAL
        safeTrace.apiEnvironment = .staging
        #endif
    }
}
