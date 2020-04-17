import UIKit

public final class CTZNTrace {
    private let environment = TracerEnvironment()
    internal lazy var tracer = ContactTracer(environment: environment)
    
    public static let shared = CTZNTrace()
    
    public var isTracing: Bool {
        return tracer.isTracingActive
    }
    
    public func startIfEnabled() {
        tracer.startScanning()
    }
    
    public func stop() {
        tracer.stopScanning()
    }
    
    public func flushPendingTraces() {
        tracer.reportPendingTraces()
    }
    
    public func refreshTraceIDsIfNeeded() {
        environment.traceIDs.refreshIfNeeded()
    }
    
    public func contactCenterViewController() -> UIViewController {
        fatalError("not implemented")
    }
    
    public func optInOutViewController() -> UIViewController {
        let navigationController = UINavigationController()

        if environment.session.isAuthenticated {
            navigationController.viewControllers = [OptInOutViewController(environment: environment)]
        } else {
            let phoneAuthVC = PhoneAuthorizationViewController(environment: environment)
            navigationController.viewControllers = [phoneAuthVC]
        }
        
        return navigationController
    }
}
