import UIKit

protocol OnboardingStep {
    var stepCompleted: (() -> Void) { get set }
    var shouldBegin: Bool { get }
    func viewControllerToShow() -> UIViewController
}
