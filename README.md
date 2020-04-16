# ctzntrace

## Push Notification Support

In your AppDelegate's `application(_:, didFinishLaunchingWithOptions:)` method, add the line:
`UNUserNotificationCenter.current().delegate = self`

Declare conformance to `UNUserNotificationCenterDelegate` as follows:
```
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler( [.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
```