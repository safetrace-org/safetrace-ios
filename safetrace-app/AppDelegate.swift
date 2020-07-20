import SafeTrace
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let environment: Environment = AppEnvironment()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SafeTrace.registerErrorHandler { error in
            var params = error.meta
            params["error"] = error.error
            params["context"] = error.context
            self.environment.analytics.track(event: TracingAnalytic.traceError, params: params)
        }
        SafeTrace.registerUserIDChangeHandler { userID in
            guard let userID = userID else { return }
            self.environment.analytics.identify(userID: userID)
        }
        
        environment.safeTrace.application(application, didFinishLaunchingWithOptions: launchOptions)
        UNUserNotificationCenter.current().delegate = self
        
        self.window = UIWindow()        
        self.window?.rootViewController = MainNavigationController(environment: environment)
        self.window?.makeKeyAndVisible()
        
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        environment.analytics.track(event: SystemAnalytic.appLaunch, params: [
            "bluetooth": launchOptions?[.bluetoothCentrals] != nil
                || launchOptions?[.bluetoothPeripherals] != nil,
            "notification": launchOptions?[.remoteNotification] != nil,
            "isBackground": application.applicationState == .background
        ])

        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        environment.analytics.track(event: SystemAnalytic.appForeground)
        environment.safeTrace.applicationWillEnterForeground(application)
        
        // Re-sync push token in case it changed
        environment.notificationPermissions.getCurrentAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        environment.analytics.track(event: SystemAnalytic.appBackground)
        environment.safeTrace.applicationDidEnterBackground(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        environment.analytics.track(event: SystemAnalytic.appTerminated)
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        environment.safeTrace.sendHealthCheck(wakeReason: .backgroundFetch) {
            completionHandler(.newData)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler( [.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        environment.safeTrace.sendHealthCheck(wakeReason: .silentNotification) {
            completionHandler(.newData)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        environment.safeTrace.session.setAPNSToken(deviceToken)
    }
}
