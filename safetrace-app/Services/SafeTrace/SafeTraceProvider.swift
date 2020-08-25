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

    var safePassURL: URL {
        switch SafeTrace.apiEnvironment {
        case .staging:
            return URL(string: "https://staging.sp0n.io/tracing/center")!
        case .production:
            return URL(string: "https://citizen.com/tracing/center")!
        }
    }

    func setHasOptedInOnce() {
        UserDefaults.standard.set(true, forKey: "org.ctzn.hasOptedInOnce")
    }

    func getHasOptedInOnce() -> Bool {
        return UserDefaults.standard.bool(forKey: "org.ctzn.hasOptedInOnce")
    }

    func startTracing() {
        SafeTrace.startTracing()
    }

    func stopTracing() {
        SafeTrace.stopTracing()
    }

    func sendHealthCheck(wakeReason: WakeReason, completion: (() -> Void)? = nil) {
        SafeTrace.sendHealthCheck(wakeReason: wakeReason, completion: completion)
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
