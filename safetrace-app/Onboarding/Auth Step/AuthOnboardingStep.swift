import Foundation
import SafeTrace
import UIKit

class AuthOnboardingStep: OnboardingStep {
    var stepCompleted: (() -> Void)
    private let environment: Environment

    init(environment: Environment, completionHandler: @escaping (() -> Void)) {
        self.environment = environment
        stepCompleted = completionHandler
    }

    var shouldBegin: Bool {
        return !environment.safeTrace.session.isAuthenticated
    }

    func viewControllerToShow() -> UIViewController {
        return IntroViewController(environment: environment, onboardingStep: self)
    }
}
