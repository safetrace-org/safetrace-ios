import UIKit

public final class SafeTrace {
    private static let environment = TracerEnvironment()
    
    public static var session: SafeTraceSession {
        environment.session
    }
    
    public static var isTracing: Bool {
        return environment.tracer.isTracingActive
    }
    
    /// Will start the scanning process. May only be called once authenticated.
    public static func startTracing() {
        guard session.isAuthenticated else {
            preconditionFailure("Cannot start scanning until authenticated.")
        }
        
        environment.tracer.optIn()
    }
    
    public static func stopTracing() {
        environment.tracer.optOut()
    }

    /// Vends a view controller contaning the Contact Center web app.
    public static func contactCenterViewController() -> UIViewController {
        fatalError("not implemented")
    }
    
    /// Must be called from the corresponding App Delegate method.
    ///
    /// Will start tracing, if enabled. If the app is being launched in the
    /// foreground, or for background fetch activity, will initiate batch
    /// reporting and update the traceID cache.
    public static func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // check if we're launching for foreground or background,
        // and then do some combination of the following:
        
        environment.traceIDs.refreshIfNeeded()
        environment.tracer.reportPendingTraces()
        environment.tracer.startScanning()
    }
}

#if STAGING || DEBUG
extension SafeTrace {
    public static var debug_notificationsEnabled: Bool {
        get { Debug.notificationsEnabled }
        set { Debug.notificationsEnabled = newValue }
    }
}
#else
extension SafeTrace {
    public static var debug_notificationsEnabled: Bool {
        get { false }
        set { }
    }
}
#endif
