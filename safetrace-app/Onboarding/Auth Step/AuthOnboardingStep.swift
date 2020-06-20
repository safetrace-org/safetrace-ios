import Foundation
import SafeTrace
import UIKit

class AuthOnboardingStep: OnboardingStep {
    var stepCompleted: (() -> Void)

    init(completionHandler: @escaping (() -> Void)) {
        stepCompleted = completionHandler
    }

    var shouldBegin: Bool {
        return !SafeTrace.session.isAuthenticated
    }

    func viewControllerToShow() -> UIViewController {
        return IntroViewController(onboardingStep: self)
    }
}
