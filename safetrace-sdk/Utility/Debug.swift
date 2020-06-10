import Foundation
import UserNotifications

internal let debugNotifsDefaultsIdentifier = "org.ctzn.debug_notifications"
private var debugNotificationsEnabled = UserDefaults.standard.bool(forKey: debugNotifsDefaultsIdentifier)

internal enum Debug {
    
    static var notificationsEnabled: Bool {
        get {
            return debugNotificationsEnabled
        }
        set {
            debugNotificationsEnabled = newValue
            UserDefaults.standard.set(newValue, forKey: debugNotifsDefaultsIdentifier)
        }
    }
    
    static func notify(
        title: String,
        body: String,
        identifier: String
    ) {
        guard notificationsEnabled else { return }
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { _ in }
    }
}
