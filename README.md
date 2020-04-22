# SafeTrace [![Build Status](https://app.bitrise.io/app/4dfbd089ca815827/status.svg?token=IRZo5KIki0lQ4w75l7zFwQ&branch=master)](https://app.bitrise.io/app/4dfbd089ca815827)

COVID-19 Contact Tracing App & SDK

## Integration Guide


#### Push Notification Support

In your AppDelegate's `application(_:, didFinishLaunchingWithOptions:)` method, add the line:
`UNUserNotificationCenter.current().delegate = self`

Declare conformance to `UNUserNotificationCenterDelegate` as follows:
```swift
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler( [.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
```

## Contributing

### Tests
We use [SwiftyMocky](https://github.com/MakeAWishFoundation/SwiftyMocky) for test mocks. To update tests, make sure the CLI tool is [installed](https://github.com/MakeAWishFoundation/SwiftyMocky#installation). The easiest way is by using Mint:

```bash
> brew install mint
> mint install MakeAWishFoundation/SwiftyMocky
```

Once SwiftyMocky is installed, mocks may be generated using the command:

```bash
> swiftymocky generate
```
