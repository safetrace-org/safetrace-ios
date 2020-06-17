import SafeTrace
import UIKit

class MainNavigationController: UINavigationController {

    lazy var authOnboardingStep = AuthOnboardingStep(completionHandler: goToNextScreen)
    lazy var onboardingSteps: [OnboardingStep] = [
        authOnboardingStep,
        BluetoothOnboardingStep(completionHandler: goToNextScreen)
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
            setViewControllers([ContactCenterViewController()], animated: true)
        }
    }

    func logout() {
        let authViewController = authOnboardingStep.viewControllerToShow()
        viewControllers.insert(authViewController, at: 0)

        popToRootViewController(animated: true)
    }

}
