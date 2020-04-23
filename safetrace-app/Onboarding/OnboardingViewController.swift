import UIKit

class OnboardingViewController: UIViewController {

    var onboardingStep: OnboardingStep

    init(onboardingStep: OnboardingStep) {
        self.onboardingStep = onboardingStep
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
