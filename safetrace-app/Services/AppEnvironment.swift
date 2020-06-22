struct AppEnvironment: Environment {
    var bluetoothPermissions: BluetoothPermissionsProviding = BluetoothPermissionsProvider()
    var notificationPermissions: NotificationPermissionsProviding = NotificationPermissionsProvider()
    var safeTrace: SafeTraceProviding = SafeTraceProvider()
    var citizen: CitizenProviding = CitizenProvider()
}
