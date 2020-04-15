import UIKit

public final class ContactTracer {
    private let bluetoothManager = BluetoothManager()
    
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
        let vc = UIViewController()
        vc.view.backgroundColor = .magenta
        return vc
    }
}
