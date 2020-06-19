#if INTERNAL
import UIKit

extension UIWindow {
    
    override open func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        
        if let rootVC = self.rootViewController {
            let debugVC = DebugViewController()
            rootVC.present(debugVC, animated: true, completion: nil)
        }
    }
}
#endif
