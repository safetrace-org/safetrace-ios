import SafeTrace
import UIKit

class MainNavigationController: UINavigationController {

    lazy var authOnboardingStep = AuthOnboardingStep(completionHandler: goToNextScreen)
    lazy var onboardingSteps: [OnboardingStep] = [
        authOnboardingStep
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        goToNextScreen()
    }

    func goToNextScreen() {
        if let onboardingStep = onboardingSteps.first(where: { $0.shouldBegin }) {
            let nextOnboardingController = onboardingStep.viewControllerToShow()
            if viewControllers.count == 0 {
                viewControllers = [nextOnboardingController]
            } else {
                pushViewController(nextOnboardingController, animated: true)
            }
        } else {
            setViewControllers([ContactTracingViewController()], animated: true)
        }
    }

}
