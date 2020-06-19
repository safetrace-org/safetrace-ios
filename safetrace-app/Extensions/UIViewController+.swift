import ReactiveSwift
import UIKit

public struct AlertData<T> {
    public let title: String?
    public let message: String?
    public let actions: [Action]

    public struct Action {
        public let title: String
        public let style: UIAlertAction.Style
        public let tapAction: T?

        public init(title: String, style: UIAlertAction.Style = .default, tapAction: T? = nil) {
            self.title = title
            self.style = style
            self.tapAction = tapAction
        }

        public static var cancel: Action {
            Action(
                title: NSLocalizedString("Cancel", comment: "Cancel button on Alerts"),
                style: .cancel,
                tapAction: T?.none
            )
        }
        public static func cancel(title: String) -> Action {
            return Action(title: title, style: .cancel, tapAction: T?.none)
        }
    }

    public init(title: String? = nil, message: String? = nil, actions: [Action]) {
        self.title = title
        self.message = message
        self.actions = actions
    }
}

extension UIViewController {
    @discardableResult
    public func displayAlert<T>(_ alert: AlertData<T>) -> Signal<T, Never> {
        let tapActionPipe = Signal<T, Never>.pipe()
        let alertController = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)

        for action in alert.actions {
            let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
                if let tapAction = action.tapAction {
                    tapActionPipe.input.send(value: tapAction)
                }
            }
            alertController.addAction(alertAction)
        }

        alertController.popoverPresentationController?.sourceView = self.view
        present(alertController, animated: true, completion: nil)

        return tapActionPipe.output
    }
}
