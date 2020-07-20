import UIKit

public enum WakeReason: String, Encodable {
    case appOpen = "app_open"
    case silentNotification = "silent_notification"
    case backgroundFetch = "background_fetch"
    case appForeground = "app_foreground"
    case appBackground = "app_background"
}

public final class SafeTrace {
    private static let environment = TracerEnvironment()
    
    public static var session: SafeTraceSession {
        environment.session
    }
    
    public static var isOptedIn: Bool {
        return environment.tracer.isTracingEnabled
    }
    
    public static var isTracing: Bool {
        return environment.tracer.isTracingActive
    }
    
    public static var apiEnvironment: NetworkEnvironment {
        get { return networkEnvironment }
        set { networkEnvironment = newValue }
    }
    
    /// Will start the scanning process. May only be called once authenticated.
    public static func startTracing() {
        guard let userID = environment.session.userID else {
            preconditionFailure("Cannot start scanning until authenticated.")
        }
        
        environment.tracer.optIn()
        environment.network.setTracingEnabled(
            true,
            userID: userID,
            completion: { _ in })
    }

    public static func stopTracing() {
        environment.tracer.optOut()
        
        if let userID = environment.session.userID {
            environment.network.setTracingEnabled(
                false,
                userID: userID,
                completion: { _ in })
        }
    }
    
    public static func sendHealthCheck(wakeReason: WakeReason, completion: (() -> Void)? = nil) {
        guard let userID = environment.session.userID else { return }
        
        let bluetoothEnabled = environment.tracer.isBluetoothPermissionEnabled
        let isOptedIn = environment.tracer.isTracingEnabled

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let pushEnabled = settings.authorizationStatus == .authorized
            
            environment.network.sendHealthCheck(
                userID: userID,
                bluetoothEnabled: bluetoothEnabled,
                notificationsEnabled: pushEnabled,
                wakeReason: wakeReason,
                isOptedIn: isOptedIn,
                appVersion: "1.1",
                bluetoothHardwareEnabled: true,
                batteryLevel: 100,
                isLowPowerMode: false
            ) { result in
                    completion?()

                    switch result {
                    case .success:
                        Debug.notify(
                            title: "Health Check Sent",
                            body: "Error: None",
                            identifier: UUID().uuidString
                        )
                    case .failure(let error):
                        Debug.notify(
                            title: "Health Check Sent",
                            body: "Error: \(error.localizedDescription)",
                            identifier: UUID().uuidString
                        )
                    }
                }

            Debug.notify(
                title: "Sending Health Check",
                body: "Wake Reason: \(wakeReason.rawValue)",
                identifier: UUID().uuidString
            )
        }
    }

    /// Must be called from the corresponding App Delegate method.
    ///
    /// Will start tracing, if enabled. If the app is being launched in the
    /// foreground, or for background fetch activity, will initiate batch
    /// reporting and update the traceID cache.
    public static func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if (launchOptions?[.bluetoothCentrals] != nil
            || launchOptions?[.bluetoothPeripherals] != nil) {
  
            // If we're launching for bluetooth background activity, start scanning only
            // but do not perform any networking side effects
            environment.tracer.startScanning()
        } else {
            environment.tracer.startScanning()
            environment.traceIDs.refreshIfNeeded()
            environment.tracer.reportPendingTraces()
            
            let isFromRemotePush = launchOptions?[.remoteNotification] != nil
            let task = UIApplication.shared.beginBackgroundTask()
            sendHealthCheck(wakeReason: isFromRemotePush ? .silentNotification : .appOpen) {
                UIApplication.shared.endBackgroundTask(task)
            }
        }
    }
    
    public static func applicationWillEnterForeground(_ application: UIApplication) {
        environment.traceIDs.refreshIfNeeded()
        environment.tracer.reportPendingTraces()
        environment.session.updateAuthTokenWebViewCookies(authToken: environment.session.authToken)
        sendHealthCheck(wakeReason: .appForeground)
    }
    
    public static func applicationDidEnterBackground(_ application: UIApplication) {
        let task = UIApplication.shared.beginBackgroundTask()
        sendHealthCheck(wakeReason: .appBackground) {
            UIApplication.shared.endBackgroundTask(task)
        }
    }
    
    public static func registerErrorHandler(_ handler: @escaping (TraceError) -> Void) {
        environment.tracer.errorHandler = handler
    }
}

extension SafeTrace {
    public static var debug_notificationsEnabled: Bool {
        get { Debug.notificationsEnabled }
        set { Debug.notificationsEnabled = newValue }
    }
}
