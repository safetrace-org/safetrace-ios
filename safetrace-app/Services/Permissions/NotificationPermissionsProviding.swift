import UIKit
import UserNotifications

protocol NotificationPermissionsProviding {
    func getCurrentAuthorization(completion: @escaping (UNAuthorizationStatus) -> Void)
    func requestPushNotifications(completion: @escaping (_ success: Bool) -> Void)
}

struct NotificationPermissionsProvider: NotificationPermissionsProviding {
    func getCurrentAuthorization(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }

    func requestPushNotifications(completion: @escaping (_ success: Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
            DispatchQueue.main.async {
                completion(success)
                #if targetEnvironment(simulator)
                return
                #else
                UIApplication.shared.registerForRemoteNotifications()
                #endif
            }
        }
    }
}
