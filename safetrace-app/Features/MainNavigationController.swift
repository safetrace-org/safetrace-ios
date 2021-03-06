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
            let contactTracingViewController = ContactTracingViewController(environment: environment, showCloseButton: false)
            setViewControllers([contactTracingViewController], animated: true)
        }
    }

    func transitionToSafePass() {
        WebViewHelper.launchWebViewController(
            url: environment.safeTrace.safePassURL,
            showCloseButton: false,
            environment: self.environment
        ) { webViewController in

            self.setViewControllers([webViewController], animated: true)
        }
    }

}
