import UIKit

protocol OnboardingStep: class {
    var stepCompleted: (() -> Void) { get set }
    var shouldBegin: Bool { get }
    func viewControllerToShow() -> UIViewController
}
