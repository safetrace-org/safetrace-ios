import UIKit

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
    
    public static func sendHealthCheck(fromNotification: Bool = false, completion: (() -> Void)? = nil) {
        guard let userID = environment.session.userID else { return }
        
        let bluetoothEnabled = environment.tracer.isBluetoothPermissionEnabled
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let pushEnabled = settings.authorizationStatus == .authorized
            
            environment.network.sendHealthCheck(
                userID: userID,
                bluetoothEnabled: bluetoothEnabled,
                notificationsEnabled: pushEnabled,
                fromNotification: fromNotification) { result in
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
                body: "From silent push: \(fromNotification)",
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
        setFirstTimeDefaultIfNeeded()
        if (launchOptions?[.bluetoothCentrals] != nil
            || launchOptions?[.bluetoothPeripherals] != nil) {
  
            // If we're launching for bluetooth background activity, start scanning only
            // but do not perform any networking side effects
            environment.tracer.startScanning()
        } else {
            environment.tracer.startScanning()
            environment.traceIDs.refreshIfNeeded()
            environment.tracer.reportPendingTraces()
            sendHealthCheck()
        }
    }

    /// Since we save userID and token on keychain, its persisted even if app is deleted
    static func setFirstTimeDefaultIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: "org.ctzn.firstInstall") else { return }

        UserDefaults.standard.set(true, forKey: "org.ctzn.firstInstall")
        environment.session.logout()
    }
    
    public static func applicationWillEnterForeground(_ application: UIApplication) {
        environment.traceIDs.refreshIfNeeded()
        environment.tracer.reportPendingTraces()
        environment.session.updateAuthTokenWebViewCookies(authToken: environment.session.authToken)
        sendHealthCheck()
    }
    
    public static func applicationDidEnterBackground(_ application: UIApplication) {
        sendHealthCheck()
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
