import CoreLocation
import UIKit

public enum WakeReason: String, Encodable {
    case appOpen = "app_open"
    case silentNotification = "silent_notification"
    case backgroundFetch = "background_fetch"
    case appForeground = "app_foreground"
    case appBackground = "app_background"
    case bluetooth = "bluetooth"
    case permissionsAsked = "permissions_asked"
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

    public static var applicationUserAgent: String?
    
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
        let appVersion = UIApplication.clientApplicationVersionShortDescription
        let bluetoothHardwareEnabled = environment.tracer.isBluetoothHardwareEnabled
        let locationAuthorization = CLLocationManager.authorizationStatus()
                let locationEnabled = locationAuthorization == .authorizedAlways
                    || locationAuthorization == .authorizedWhenInUse
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        let isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled

        let task = UIApplication.shared.beginBackgroundTask()
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let pushEnabled = settings.authorizationStatus == .authorized
            
            environment.network.sendHealthCheck(
                userID: userID,
                bluetoothEnabled: bluetoothEnabled,
                notificationsEnabled: pushEnabled,
                locationEnabled: locationEnabled,
                wakeReason: wakeReason,
                isOptedIn: isOptedIn,
                appVersion: appVersion,
                bluetoothHardwareEnabled: bluetoothHardwareEnabled,
                batteryLevel: batteryLevel,
                isLowPowerMode: isLowPowerMode
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
                
                    UIApplication.shared.endBackgroundTask(task)
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
            sendHealthCheckForBluetoothWakeIfNeeded()
        } else {
            environment.tracer.startScanning()
            environment.traceIDs.refreshIfNeeded()
            environment.tracer.reportPendingTraces()
            
            let isFromRemotePush = launchOptions?[.remoteNotification] != nil
            sendHealthCheck(wakeReason: isFromRemotePush ? .silentNotification : .appOpen)
        }
    }
    
    public static func applicationWillEnterForeground(_ application: UIApplication) {
        environment.network.resetURLSession()
        environment.traceIDs.refreshIfNeeded()
        environment.tracer.reportPendingTraces()
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

    public static func registerUserIDChangeHandler(_ handler: @escaping (String?) -> Void) {
        environment.session.userIDDidChange = handler
        handler(environment.session.userID)
    }
    
    private static func sendHealthCheckForBluetoothWakeIfNeeded() {
        let key = "org.ctzn.last_bluetooth_health_check"
        let now = Date()

        let sendCheck = {
            sendHealthCheck(wakeReason: .bluetooth)
            environment.tracer.reportPendingTraces()
            environment.defaults.set(now, forKey: key)
        }

        if let lastWake = environment.defaults.object(forKey: key) as? Date {
            if lastWake.addingTimeInterval(3600) <= now {
                sendCheck()
            }
        } else {
            sendCheck()
        }
    }

    public static func syncLocation(_ location: LocationRequest, completion: (() -> Void)? = nil) {
            guard let userID = environment.session.userID else { return }
            let task = UIApplication.shared.beginBackgroundTask()

            environment.network.syncLocation(location, userID: userID) { _ in
                completion?()
                UIApplication.shared.endBackgroundTask(task)
            }
        }
}

extension SafeTrace {
    public static var debug_notificationsEnabled: Bool {
        get { Debug.notificationsEnabled }
        set { Debug.notificationsEnabled = newValue }
    }
}
