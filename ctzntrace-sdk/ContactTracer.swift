import UIKit

public final class ContactTracer {
    public let shared = ContactTracer()
    
    var isTracing: Bool
    
    func startIfEnabled() {
        
    }
    
    func stop() {
        
    }
    
    func contactCenterViewController() -> UIViewController {
        fatalError("not implemented")
    }
    
    func optInOutViewController() -> UIViewController {
        fatalError("not implemented")
    }
    
    private init() {
        isTracing = false
    }
}
