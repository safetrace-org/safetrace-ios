import SafeTrace
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SafeTrace.application(application, didFinishLaunchingWithOptions: launchOptions)
        UNUserNotificationCenter.current().delegate = self
        
        self.window = UIWindow()        
        self.window?.rootViewController = MainNavigationController()
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        SafeTrace.applicationWillEnterForeground(application)
        
        // Re-sync push token in case it changed
        NotificationPermissions.getCurrentAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        SafeTrace.applicationDidEnterBackground(application)
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        SafeTrace.sendHealthCheck {
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
        SafeTrace.sendHealthCheck {
            completionHandler(.newData)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        SafeTrace.session.setAPNSToken(deviceToken)
    }
}
