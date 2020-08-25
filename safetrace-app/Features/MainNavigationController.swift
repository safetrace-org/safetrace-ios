import SafeTrace
import UIKit

class MainNavigationController: UINavigationController {
    private let environment: Environment
    private lazy var authOnboardingStep = AuthOnboardingStep(environment: environment, completionHandler: goToNextScreen)
    private lazy var onboardingSteps: [OnboardingStep] = [
        authOnboardingStep
    ]

    init(environment: Environment) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        } else if environment.safeTrace.getHasOptedInOnce() || environment.safeTrace.isOptedIn {
            transitionToSafePass()
        } else {
            setViewControllers([ContactTracingViewController(environment: environment)], animated: true)
        }
    }

    func transitionToSafePass() {
        let webViewController = WebViewController(environment: environment, showCloseButton: false)
        webViewController.loadUrl(environment.safeTrace.safePassURL)

        setViewControllers([webViewController], animated: true)
    }

}
