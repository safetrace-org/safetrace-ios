import UIKit

public final class ContactTracer {
    private let environment = TracerEnvironment()
    internal lazy var bluetoothManager = BluetoothManager(environment: environment)
    
    public static let shared = ContactTracer()
    
    public var isTracing: Bool {
        return bluetoothManager.isTracingActive
    }
    
    public func startIfEnabled() {
        bluetoothManager.startScanning()
    }
    
    public func stop() {
        bluetoothManager.stopScanning()
    }
    
    public func flushPendingTraces() {
        bluetoothManager.reportPendingTraces()
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
