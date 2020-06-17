import Foundation
import UIKit

class BluetoothOnboardingStep: OnboardingStep {
    var stepCompleted: (() -> Void)

    required init(completionHandler: @escaping (() -> Void)) {
        stepCompleted = completionHandler
    }

    var shouldBegin: Bool {
        return !BluetoothPermissions.isEnabled
    }

    func viewControllerToShow() -> UIViewController {
        if BluetoothPermissions.isNotDetermined {
            return BluetoothPermissionsViewController(onboardingStep: self)
        } else {
            return BluetoothRequiredViewController(onboardingStep: self)
        }
    }
}
