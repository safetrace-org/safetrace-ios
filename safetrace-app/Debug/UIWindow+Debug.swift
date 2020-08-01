import UIKit

extension UIWindow {
    
    override open func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        
        if let rootVC = self.rootViewController {
            let debugVC = DebugViewController()
            let navVC = UINavigationController(rootViewController: debugVC)
            navVC.modalPresentationStyle = .fullScreen
            rootVC.present(navVC, animated: true, completion: nil)
        }
    }
}
