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

    func startTracing() {
        SafeTrace.startTracing()
    }

    func stopTracing() {
        SafeTrace.stopTracing()
    }

    func sendHealthCheck(completion: (() -> Void)? = nil) {
        SafeTrace.sendHealthCheck(completion: completion)
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
