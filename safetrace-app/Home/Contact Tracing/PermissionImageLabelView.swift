import UIKit

class PermissionIconLabelView: UIStackView {
    enum PermissionType {
        case bluetooth
        case notification
    }

    let imageView = UIImageView()
    let label = UILabel()
    let tapRecognizer = UITapGestureRecognizer()

    private let permissionType: PermissionType

    var showErrorState: Bool = false {
        didSet {
            updateUI()
        }
    }

    init(permissionType: PermissionType) {
        self.permissionType = permissionType
        super.init(frame: .zero)

        update(self, ContactTracingStyle.imageLabelStackView)

        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapRecognizer)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)

        imageView.image = permissionType.image
        update(imageView, ContactTracingStyle.imageLabelIcon)

        addArrangedSubview(imageView)
        addArrangedSubview(label)

        updateUI()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateUI() {
        imageView.tintColor = showErrorState
            ? .stRed
            : .stGrey40

        label.attributedText = permissionType.label(showErrorState: showErrorState)
    }
}

private extension PermissionIconLabelView.PermissionType {
    var image: UIImage {
        switch self {
        case .bluetooth:
            return UIImage(named: "contactTracingBluetoothIcon")!.withRenderingMode(.alwaysTemplate)
        case .notification:
            return UIImage(named: "contactTracingNotificationIcon")!.withRenderingMode(.alwaysTemplate)
        }
    }

    func label(showErrorState: Bool) -> NSAttributedString {
        return showErrorState
            ? errorStateAttributedText
            : normalAttributedString
    }

    private var normalAttributedString: NSAttributedString {
        let permissionsText: String
        switch self {
        case .bluetooth:
            permissionsText = NSLocalizedString("Bluetooth permissions are required.", comment: "Bluetooth permissions required text")
        case .notification:
            permissionsText = NSLocalizedString("Notification permissions are required.", comment: "Notification permissions required text")
        }

        return NSAttributedString(string: permissionsText, attributes: [
            .font: UIFont.bodyBold,
            .foregroundColor: UIColor.stGrey40
        ])
    }

    private var errorStateAttributedText: NSAttributedString {
        let permissionsText: String
        switch self {
        case .bluetooth:
            permissionsText = NSLocalizedString("Bluetooth permissions are required.", comment: "Bluetooth permissions error text")
        case .notification:
            permissionsText = NSLocalizedString("Notification permissions are required.", comment: "Notification permissions error text")
        }
        let goToSettingsText = NSLocalizedString("Go to Settings", comment: "Go to Settings")

        let permissionsErrorTemplate = NSLocalizedString(
            "%1$@\n%2$@ to enable.",
            comment: "Permissions disabled error template"
        )
        let permissionsErrorString = String(format: permissionsErrorTemplate, permissionsText, goToSettingsText)

        let attributedString = NSMutableAttributedString(
            string: permissionsErrorString,
            attributes: [
                .font: UIFont.bodyBold,
                .foregroundColor: UIColor.stGrey55,
            ])

        let permissionsTextRange = attributedString.mutableString.range(of: permissionsText)
        let permissionsTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.stRed
        ]
        attributedString.addAttributes(permissionsTextAttributes, range: permissionsTextRange)

        let goToSettingsTextRange = attributedString.mutableString.range(of: goToSettingsText)
        let goToSettingsTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.stBlue
        ]
        attributedString.addAttributes(goToSettingsTextAttributes, range: goToSettingsTextRange)

        return attributedString
    }
}

