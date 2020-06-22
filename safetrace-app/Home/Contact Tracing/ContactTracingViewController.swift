import ReactiveSwift
import ReactiveCocoa
import SafeTrace
import UIKit
import UserNotifications

struct ContactTracingStyle {
    static func imageLabelStackView(_ stackView: UIStackView) {
        stackView.axis = .horizontal
        stackView.spacing = 7
        stackView.alignment = .top
        stackView.distribution = .fill
    }

    static func imageLabelIcon(_ imageView: UIImageView) {
        imageView.contentMode = .center
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 10),
            imageView.heightAnchor.constraint(equalToConstant: 16),
        ])
    }
}

class ContactTracingViewController: UIViewController {
    private let environment: Environment

    private let citizenLogoView = UIImageView()
    private let titleLabel = UILabel()
    private let enabledLabel = UILabel()
    private let toggle = UISwitch()
    private let learnMoreButton = Button(style: .secondary)

    private let bluetoothIconLabelView = PermissionIconLabelView(permissionType: .bluetooth)
    private let notificationIconLabelView = PermissionIconLabelView(permissionType: .notification)

    private let stackViewTopSpacing: CGFloat = UIScreen.main.isSmallScreen ? 10 : 80
    private let trayTopSpacingToToggle: CGFloat = 20

    private let viewDidLoadPipe = Signal<Void, Never>.pipe()
    private let tapDescriptionTextPipe = Signal<Void, Never>.pipe()
    private let tapBluetoothPermissionsTextPipe = Signal<Void, Never>.pipe()
    private let tapNotificationPermissionsTextPipe = Signal<Void, Never>.pipe()
    private let tapPrivacyTextPipe = Signal<Void, Never>.pipe()
    private let tapTermsTextPipe = Signal<Void, Never>.pipe()
    private let goToSettingsAlertActionPipe = Signal<Void, Never>.pipe()
    private let notificationPermissionsChangedPipe = Signal<UNAuthorizationStatus, Never>.pipe()

    init(environment: Environment) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        defer {
            viewDidLoadPipe.input.send(value: ())
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
            environment: environment,
            toggleIsOn: toggle.reactive.controlEvents(.valueChanged).map { $0.isOn },
            appBecameActive: appBecameActiveSignal,
            notificationPermissionsChanged: notificationPermissionsChangedPipe.output,
            tapDescriptionText: tapDescriptionTextPipe.output,
            tapBluetoothPermissionsText: tapBluetoothPermissionsTextPipe.output,
            tapNotificationPermissionsText: tapNotificationPermissionsTextPipe.output,
            tapPrivacyText: tapPrivacyTextPipe.output,
            tapTermsText: tapTermsTextPipe.output,
            tapLearnMoreButton: learnMoreButton.reactive.controlEvents(.touchUpInside).map(value: ()),
            goToSettingsAlertAction: goToSettingsAlertActionPipe.output,
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
            .observeValues { [weak self] in
                self?.environment.safeTrace.startTracing()
            }

        optOut
            .take(during: self.reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.environment.safeTrace.stopTracing()
            }

        askBluetoothPermissions
            .take(during: self.reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.environment.bluetoothPermissions.requestPermissions()
            }

        askNotificationPermissions
            .take(during: self.reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.environment.notificationPermissions.requestPushNotifications { [weak self] success in
                    self?.notificationPermissionsChangedPipe.input.send(value: success ? .authorized : .denied)
                }
            }

        navigateToAppSettings
            .take(during: self.reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.environment.bluetoothPermissions.openSettings()
            }

        openWebView
            .take(during: self.reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [weak self] url in
                let webViewController = WebViewController()
                webViewController.loadUrl(url)
                self?.present(webViewController, animated: true)
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
        toggle.setOn(viewData.isOptedIn, animated: true)

        enabledLabel.text = viewData.tracingStatus == .enabled
            ? NSLocalizedString("Enabled", comment: "Enabled contact tracing status")
            : NSLocalizedString("Disabled", comment: "Disabled contact tracing status")

        switch viewData.tracingStatus {
        case .defaultDisabled:
            enabledLabel.textColor = .stGrey40
            toggle.alpha = 1
        case .enabled:
            enabledLabel.textColor = .stPurpleAccentUp
            toggle.alpha = 1
        case .error:
            enabledLabel.textColor = .stRed
            toggle.alpha = 0.6
        }

        bluetoothIconLabelView.showErrorState = viewData.bluetoothDenied
        notificationIconLabelView.showErrorState = viewData.notificationDenied
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

        toggle.isOn = environment.safeTrace.isOptedIn
        toggle.onTintColor = .stPurple
        toggle.scale(by: 2.5)
        toggle.setOffColor(.stGrey25)

        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0

        let enableText = NSLocalizedString("enabling Citizen SafeTrace", comment: "enable safetrace highlighted text")
        let descriptionTemplate = NSLocalizedString("Protect yourself, your loved ones, and your community from COVID-19 by %@.", comment: "Safetrace description template")
        let descriptionText = String(format: descriptionTemplate, enableText)

        let descriptionAttributedText = NSMutableAttributedString(
            string: descriptionText,
            attributes: [
                .font: UIFont.titleH3,
                .foregroundColor: UIColor.stGrey55,
            ])
        descriptionAttributedText.addAttributes(
            [.foregroundColor: UIColor.stPurpleAccentUp],
            range: descriptionAttributedText.mutableString.range(of: enableText))
        descriptionLabel.attributedText = descriptionAttributedText

        descriptionLabel.isUserInteractionEnabled = true
        let descriptionLabelRecognizer = UITapGestureRecognizer()
        descriptionLabel.addGestureRecognizer(descriptionLabelRecognizer)
        tapDescriptionTextPipe.input <~ descriptionLabelRecognizer.reactive.stateChanged.map(value: ())

        tapBluetoothPermissionsTextPipe.input <~ bluetoothIconLabelView.tapRecognizer.reactive.stateChanged.map(value: ())

        tapNotificationPermissionsTextPipe.input <~ notificationIconLabelView.tapRecognizer.reactive.stateChanged.map(value: ())

        let privacyIcon = UIImageView()
        privacyIcon.image = UIImage(named: "contactTracingPrivacyIcon")!
        update(privacyIcon, ContactTracingStyle.imageLabelIcon)

        let privacyTextView = makePrivacyAndTermsTextView()
        privacyTextView.setContentCompressionResistancePriority(.required, for: .horizontal)

        let privacyImageLabelView = UIStackView(arrangedSubviews: [privacyIcon, privacyTextView])
        update(privacyImageLabelView, ContactTracingStyle.imageLabelStackView)

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)

        let stackView = UIStackView(arrangedSubviews: [
            citizenLogoView,
            titleLabel,
            enabledLabel,
            toggleContainer,
            descriptionLabel,
            bluetoothIconLabelView,
            notificationIconLabelView,
            privacyImageLabelView,
            spacer
        ])
        stackView.axis = .vertical
        stackView.alignment = .leading

        stackView.setCustomSpacing(12, after: citizenLogoView)
        stackView.setCustomSpacing(20, after: enabledLabel)
        stackView.setCustomSpacing(UIScreen.main.isSmallScreen ? trayTopSpacingToToggle : 34, after: toggleContainer)
        stackView.setCustomSpacing(UIScreen.main.isSmallScreen ? 14 : 30, after: descriptionLabel)
        stackView.setCustomSpacing(12, after: bluetoothIconLabelView)
        stackView.setCustomSpacing(12, after: notificationIconLabelView)
        stackView.setCustomSpacing(16, after: privacyImageLabelView)

        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.addSubview(stackView)

        view.addSubview(scrollView)

        learnMoreButton.setTitle(NSLocalizedString("Learn more", comment: "Learn more button title"), for: .normal)
        view.addSubview(learnMoreButton)

        let stackViewHeightConstraint = stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        stackViewHeightConstraint.priority = .defaultLow

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        toggle.translatesAutoresizingMaskIntoConstraints = false
        learnMoreButton.translatesAutoresizingMaskIntoConstraints = false

        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: stackViewTopSpacing, left: 28, bottom: 0, right: 28)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: learnMoreButton.topAnchor, constant: -20),

            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackViewHeightConstraint,
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            citizenLogoView.widthAnchor.constraint(equalToConstant: 58),
            citizenLogoView.heightAnchor.constraint(equalToConstant: 32),

            toggle.leadingAnchor.constraint(equalTo: toggleContainer.leadingAnchor),
            toggle.topAnchor.constraint(equalTo: toggleContainer.topAnchor),

            toggleContainer.widthAnchor.constraint(equalToConstant: 144),
            toggleContainer.heightAnchor.constraint(equalToConstant: 80),

            learnMoreButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            learnMoreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            learnMoreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28)
        ])

        view.layoutIfNeeded()
    }

    private func makePrivacyAndTermsTextView() -> TappableTextView {
        let privacyAndTermsTextView = TappableTextView()

        let privacyPolicyText = NSLocalizedString("Privacy Policy", comment: "Privacy policy text")
        let termsOfUseText = NSLocalizedString("Supplemental Terms", comment: "Supplemental terms text")
        let termsAndConditionsTemplate = NSLocalizedString(
            "By enabling Citizen SafeTrace, you agree to the %1$@ and %2$@.",
            comment: "Terms of use and privacy policy text template"
        )
        let termsAndConditionsText = String(format: termsAndConditionsTemplate, privacyPolicyText, termsOfUseText)

        let attributedString = NSMutableAttributedString(
            string: termsAndConditionsText,
            attributes: [
                .font: UIFont.bodyBold,
                .foregroundColor: UIColor.stGrey40,
            ])

        let privacyPolicyCharacterRange = attributedString.mutableString.range(of: privacyPolicyText)
        let termsOfUseCharacterRange = attributedString.mutableString.range(of: termsOfUseText)
        [
            privacyPolicyCharacterRange: "privacyPolicy",
            termsOfUseCharacterRange: "supplementalTerms"
        ]
        .forEach {
            let attributes: [NSAttributedString.Key: Any] = [
                .link: $0.1,
                .foregroundColor: UIColor.stBlueMutedUp
            ]
            attributedString.addAttributes(attributes, range: $0.0)
        }

        privacyAndTermsTextView.attributedText = attributedString
        privacyAndTermsTextView.linkHandler = { [weak self] url in
            if url.absoluteString == "privacyPolicy" {
                self?.tapPrivacyTextPipe.input.send(value: ())
            } else {
                self?.tapTermsTextPipe.input.send(value: ())
            }
        }
        return privacyAndTermsTextView
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
