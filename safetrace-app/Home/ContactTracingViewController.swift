import ReactiveSwift
import ReactiveCocoa
import SafeTrace
import UIKit
import UserNotifications

class ContactTracingViewController: UIViewController {
    private let citizenLogoView = UIImageView()
    private let titleLabel = UILabel()
    private let enabledLabel = UILabel()
    private let toggle = UISwitch()
    private let bluetoothImageView = UIImageView()
    private let bluetoothLabel = UILabel()
    private let notificationImageView = UIImageView()
    private let notificationLabel = UILabel()

    private let stackViewTopSpacing: CGFloat = UIScreen.main.isSmallScreen ? 10 : 80
    private let trayTopSpacingToToggle: CGFloat = 20

    private let viewDidLoadPipe = Signal<Void, Never>.pipe()
    private let tapDescriptionTextPipe = Signal<Void, Never>.pipe()
    private let tapBluetoothPermissionsTextPipe = Signal<Void, Never>.pipe()
    private let tapNotificationPermissionsTextPipe = Signal<Void, Never>.pipe()
    private let tapPrivacyTextPipe = Signal<Void, Never>.pipe()
    private let tapTermsTextPipe = Signal<Void, Never>.pipe()
    private let goToSettingsAlertActionPipe = Signal<Void, Never>.pipe()
    private let notificationPermissionsPipe = Signal<UNAuthorizationStatus, Never>.pipe()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        defer {
            viewDidLoadPipe.input.send(value: ())
            NotificationPermissions.getCurrentAuthorization { [weak self] in
                self?.notificationPermissionsPipe.input.send(value: $0)
            }
        }

        navigationController?.setNavigationBarHidden(true, animated: false)

        layoutUI()
        bindViewModel()
    }

    private func bindViewModel() {
        // If bluetooth status changes from permissions prompts, this signal will fire when the permission prompt goes away after user has granted/denied permissions
        let appBecameActiveSignal = NotificationCenter.default.reactive
            .notifications(forName: UIApplication.didBecomeActiveNotification)
            .map(value: ())

        let (
            viewData: viewData,
            optIn: optIn,
            optOut: optOut,
            askBluetoothPermissions: askBluetoothPermissions,
            askNotificationPermissions: askNotificationPermissions,
            navigateToAppSettings: navigateToAppSettings,
            openWebView: openWebView,
            displayAlert: displayAlert
        ) = contactTracingViewModel(
            toggleIsOn: toggle.reactive.controlEvents(.valueChanged).map { $0.isOn },
            appBecameActive: appBecameActiveSignal,
            tapDescriptionText: tapDescriptionTextPipe.output,
            tapBluetoothPermissionsText: tapBluetoothPermissionsTextPipe.output,
            tapNotificationPermissionsText: tapNotificationPermissionsTextPipe.output,
            tapPrivacyText: tapPrivacyTextPipe.output,
            tapTermsText: tapTermsTextPipe.output,
            goToSettingsAlertAction: goToSettingsAlertActionPipe.output,
            notificationPermissions: notificationPermissionsPipe.output,
            viewDidLoad: viewDidLoadPipe.output
        )

        viewData
            .take(during: self.reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [weak self] viewData in
                self?.updateWithViewData(viewData)
            }

        optIn
            .take(during: self.reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues {
                SafeTrace.startTracing()
            }

        optOut
            .take(during: self.reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues {
                SafeTrace.stopTracing()
            }

        askBluetoothPermissions
            .take(during: self.reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues {
                BluetoothPermissions.requestPermissions()
            }

        askNotificationPermissions
            .take(during: self.reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues {
                NotificationPermissions.requestPushNotifications { [weak self] success in
                    self?.notificationPermissionsPipe.input.send(value: success ? .authorized : .denied)
                }
            }

        navigateToAppSettings
            .take(during: self.reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues {
                BluetoothPermissions.openSettings()
            }

        openWebView
            .take(during: self.reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { url in
                // TODO
            }

        displayAlert
            .take(during: self.reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [weak self] alert in
                guard let self = self else { return }
                self.goToSettingsAlertActionPipe.input <~ self.displayAlert(alert)
            }
    }

    private func updateWithViewData(_ viewData: ContactTracingViewData) {
        let tracingEnabled = viewData.contactTracingEnabled
        toggle.setOn(viewData.contactTracingEnabled, animated: false)
        let enabledLabelColor: UIColor = tracingEnabled
            ? .stPurpleAccentUp
            : .stGrey40
        let enabledText = tracingEnabled
            ? "Enabled"
            : "Disabled"
        enabledLabel.textColor = enabledLabelColor
        enabledLabel.text = enabledText

        bluetoothLabel.text = viewData.bluetoothDenied
            ? "*Bluetooth permissions are required.*\n**Go to Settings** to enable."
            : "Bluetooth permissions are required."
        bluetoothImageView.tintColor = viewData.bluetoothDenied
            ? .stRed
            : .stGrey40

        notificationLabel.text = viewData.notificationDenied
            ? "*Notification permissions are required.*\n**Go to Settings** to enable."
            : "Notification permissions are required."
        notificationImageView.tintColor = viewData.notificationDenied
            ? .stRed
            : .stGrey40
    }

    private func layoutUI() {
        view.backgroundColor = .stBlack

        citizenLogoView.image = UIImage(named: "citizenLogo")
        citizenLogoView.contentMode = .scaleAspectFit

        titleLabel.textColor = .stWhite
        titleLabel.font = .titleH1
        titleLabel.numberOfLines = 0

        titleLabel.text = NSLocalizedString("SafeTrace\nContact Tracing", comment: "Safetrace Title on Contact Tracing Page")

        enabledLabel.textColor = .stGrey40
        enabledLabel.font = .titleH1
        enabledLabel.text = NSLocalizedString("Disabled", comment: "Contact tracing disabled status")

        let toggleContainer = UIView()
        toggleContainer.addSubview(toggle)

        toggle.isOn = false
        toggle.onTintColor = .stPurple
        toggle.scale(by: 2.5)
        toggle.setOffColor(.stGrey25)

        let descriptionLabel = UILabel()
        descriptionLabel.font = .titleH3
        descriptionLabel.textColor = .stGrey55
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "Protect yourself, your loved ones, and your community from COVID-19 by **enabling SafeTrace**." // TODO stylize

        descriptionLabel.isUserInteractionEnabled = true
        let descriptionLabelRecognizer = UITapGestureRecognizer()
        descriptionLabel.addGestureRecognizer(descriptionLabelRecognizer)
        tapDescriptionTextPipe.input <~ descriptionLabelRecognizer.reactive.stateChanged.map(value: ())

        bluetoothLabel.text = "Bluetooth permissions are required." // TODO stylize
        bluetoothLabel.numberOfLines = 0
        bluetoothLabel.isUserInteractionEnabled = true
        bluetoothLabel.font = .bodyBold
        bluetoothLabel.textColor = .stGrey40

        let bluetoothTextRecognizer = UITapGestureRecognizer()
        bluetoothLabel.addGestureRecognizer(bluetoothTextRecognizer)
        tapBluetoothPermissionsTextPipe.input <~ bluetoothTextRecognizer.reactive.stateChanged.map(value: ())

        let bluetoothTextContainer = layoutImageLabel(
            imageView: bluetoothImageView,
            image: UIImage(named: "contactTracingBluetoothIcon")!.withRenderingMode(.alwaysTemplate),
            textContainer: bluetoothLabel
        )

        notificationLabel.text = "Notification permissions are required." // TODO stylize
        notificationLabel.numberOfLines = 0
        notificationLabel.isUserInteractionEnabled = true
        notificationLabel.font = .bodyBold
        notificationLabel.textColor = .stGrey40

        let notificationTextRecognizer = UITapGestureRecognizer()
        notificationLabel.addGestureRecognizer(notificationTextRecognizer)
        tapNotificationPermissionsTextPipe.input <~ notificationTextRecognizer.reactive.stateChanged.map(value: ())

        let notificationTextContainer = layoutImageLabel(
            imageView: notificationImageView,
            image: UIImage(named: "contactTracingNotificationIcon")!.withRenderingMode(.alwaysTemplate),
            textContainer: notificationLabel
        )

        let privacyTextView = TappableTextView()
        privacyTextView.font = .bodyBold
        privacyTextView.textColor = .stGrey40
        privacyTextView.text = "By enabling COVID-19 SafeTrace, you agree to the [Privacy Policy](privacyPolicy) and [Terms of Use](terms)." // TODO Stylize
        privacyTextView.linkHandler = { [weak self] url in
            if url.absoluteString == "privacyPolicy" {
                self?.tapPrivacyTextPipe.input.send(value: ())
            } else {
                self?.tapTermsTextPipe.input.send(value: ())
            }
        }

        let privacyTextContainer = layoutImageLabel(
            imageView: UIImageView(),
            image: UIImage(named: "contactTracingPrivacyIcon")!,
            textContainer: privacyTextView
        )

        let stackView = UIStackView(arrangedSubviews: [
            citizenLogoView,
            titleLabel,
            enabledLabel,
            toggleContainer,
            descriptionLabel,
            bluetoothTextContainer,
            notificationTextContainer,
            privacyTextContainer
        ])
        stackView.axis = .vertical
        stackView.alignment = .leading

        stackView.setCustomSpacing(12, after: citizenLogoView)
        stackView.setCustomSpacing(20, after: enabledLabel)
        stackView.setCustomSpacing(UIScreen.main.isSmallScreen ? trayTopSpacingToToggle : 34, after: toggleContainer)
        stackView.setCustomSpacing(UIScreen.main.isSmallScreen ? 14 : 30, after: descriptionLabel)
        stackView.setCustomSpacing(12, after: bluetoothTextContainer)
        stackView.setCustomSpacing(12, after: notificationTextContainer)
        stackView.setCustomSpacing(16, after: privacyTextContainer)

        view.addSubview(stackView)

        let titleTopConstraint = stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: stackViewTopSpacing)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        toggle.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleTopConstraint,
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
            citizenLogoView.widthAnchor.constraint(equalToConstant: 58),
            citizenLogoView.heightAnchor.constraint(equalToConstant: 32),
            toggleContainer.widthAnchor.constraint(equalToConstant: 144),
            toggleContainer.heightAnchor.constraint(equalToConstant: 80)
        ])

        view.layoutIfNeeded()
    }

    private func layoutImageLabel(
        imageView: UIImageView,
        image: UIImage,
        textContainer: UIView
    ) -> UIStackView {
        imageView.image = image
        imageView.contentMode = .scaleAspectFit

        textContainer.setContentCompressionResistancePriority(.required, for: .horizontal)

        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            textContainer
        ])
        stackView.axis = .horizontal
        stackView.spacing = 7
        stackView.alignment = .top
        stackView.distribution = .fill

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 8),
            imageView.heightAnchor.constraint(equalToConstant: 16),
        ])

        return stackView
    }

}

private extension UISwitch {
    func scale(by scaleFactor: CGFloat) {
        let toggleTranslationFactor: CGFloat = (scaleFactor - 1) / 2
        transform = CGAffineTransform(
            translationX: bounds.width * toggleTranslationFactor,
            y: bounds.height * toggleTranslationFactor
        )
        .scaledBy(x: scaleFactor, y: scaleFactor)
    }

    func setOffColor(_ color: UIColor) {
        let minSide = min(bounds.size.height, bounds.size.width)
        layer.cornerRadius = minSide / 2
        backgroundColor = color
        tintColor = color
    }
}
