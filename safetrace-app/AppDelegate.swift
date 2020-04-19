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
        let navigationController = UINavigationController()
        
        if SafeTrace.session.isAuthenticated {
            navigationController.viewControllers = [HomeViewController()]
        } else {
            navigationController.viewControllers = [PhoneAuthenticationViewController()]
        }
        
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler( [.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
