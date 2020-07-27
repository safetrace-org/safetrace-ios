import UIKit

class OnboardingViewController: UIViewController {
    let environment: Environment
    let onboardingStep: OnboardingStep

    init(environment: Environment, onboardingStep: OnboardingStep) {
        self.environment = environment
        self.onboardingStep = onboardingStep
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func goBack() {
        navigationController?.popViewController(animated: true)
    }

    func makeBackButton() -> UIButton {
        let button = BackButton()
        button.tapHandler = { [weak self] in
            self?.goBack()
        }
        return button
    }
}
