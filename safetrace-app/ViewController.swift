import SafeTrace
import UIKit

class ViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let optInVC = SafeTrace.shared.optInOutViewController()
        navigationController?.pushViewController(optInVC, animated: true)
    }
}

