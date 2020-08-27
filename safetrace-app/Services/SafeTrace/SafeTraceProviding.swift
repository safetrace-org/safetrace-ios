import Foundation
import SafeTrace
import UIKit

protocol SafeTraceProviding {
    var isOptedIn: Bool { get }
    var isTracing: Bool { get }
    var session: SafeTraceSession { get }
    var apiEnvironment: NetworkEnvironment { get set }
    var safePassURL: URL { get }

    func startTracing()
    func stopTracing()

    func sendHealthCheck(wakeReason: WakeReason, completion: (() -> Void)?)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    func applicationWillEnterForeground(_ application: UIApplication)
    func applicationDidEnterBackground(_ application: UIApplication)

    func getHasOptedInOnce() -> Bool
}
