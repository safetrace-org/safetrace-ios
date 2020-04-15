import UIKit

public final class CTZNTrace {
    public static let shared = CTZNTrace()
    
    public var isTracing: Bool
    
    public func startIfEnabled() {
        print("Starting")
    }
    
    public func stop() {
        
    }
    
    public func flushPendingTraces() {
        
    }
    
    public func contactCenterViewController() -> UIViewController {
        fatalError("not implemented")
    }
    
    public func optInOutViewController() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .magenta
        return vc
    }
    
    private init() {
        isTracing = false
    }
}
