import UIKit

@objc protocol OnboardingStep: class {
    func goBack()
}

class OnboardingViewController: UIViewController, OnboardingStep {
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }

    func makeBackButton() -> UIButton {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "backIcon"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.adjustsImageWhenHighlighted = true
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        backButton.setSize(width: 32, height: 32)
        return backButton
    }
}
