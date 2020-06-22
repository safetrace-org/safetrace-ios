import SafeTrace
import UIKit

struct SafeTraceProvider: SafeTraceProviding {
    var isOptedIn: Bool {
        return SafeTrace.isOptedIn
    }

    var isTracing: Bool {
        return SafeTrace.isTracing
    }

    var session: SafeTraceSession {
        return SafeTrace.session
    }

    var apiEnvironment: NetworkEnvironment {
        get { return SafeTrace.apiEnvironment }
        set { SafeTrace.apiEnvironment = newValue }
    }

    func setLastSuccessfullyOptedIn(_ success: Bool) {
        UserDefaults.standard.set(success, forKey: "org.ctzn.isLastSuccessfullyOptedIn")
    }

    func getLastSuccessfullyOptedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "org.ctzn.isLastSuccessfullyOptedIn")
    }

    func startTracing() {
        SafeTrace.startTracing()
    }

    func stopTracing() {
        SafeTrace.stopTracing()
    }

    func sendHealthCheck(fromNotification: Bool = false, completion: (() -> Void)? = nil) {
        SafeTrace.sendHealthCheck(fromNotification: fromNotification, completion: completion)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        SafeTrace.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        SafeTrace.applicationWillEnterForeground(application)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        SafeTrace.applicationDidEnterBackground(application)
    }

}
