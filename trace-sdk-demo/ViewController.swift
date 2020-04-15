import CTZNTrace
import UIKit

class ViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let optInVC = ContactTracer.shared.optInOutViewController()
        navigationController?.pushViewController(optInVC, animated: true)
    }
}

