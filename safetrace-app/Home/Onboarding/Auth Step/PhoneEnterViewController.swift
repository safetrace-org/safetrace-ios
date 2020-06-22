import SafariServices
import SafeTrace
import UIKit

final class PhoneEnterViewController: OnboardingViewController {
    private let phoneEnterInputView = OnboardingInputView()
    private let sendCodeButton = Button(style: .primary)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .stBlack
        navigationController?.setNavigationBarHidden(true, animated: false)

        // MARK: - UI Components

        let backButton = makeBackButton()

        let titleLabel = UILabel()
        titleLabel.font = .titleH2
        titleLabel.textColor = .stWhite
        titleLabel.text = NSLocalizedString("Enter your phone number", comment: "Phone auth title")
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.font = .titleH2
        subtitleLabel.textColor = .stGrey70
        subtitleLabel.text = NSLocalizedString("to sign up or log in.", comment: "Phone auth subtitle")
        subtitleLabel.textAlignment = .left
        subtitleLabel.numberOfLines = 0

        phoneEnterInputView.nameLabel.text = NSLocalizedString("Phone Number", comment: "Phone auth phone number label").uppercased(with: Locale.current)

        phoneEnterInputView.textField.keyboardType = .numberPad
        phoneEnterInputView.textField.delegate = self

        phoneEnterInputView.errorLabel.text = NSLocalizedString("Cannot complete request. Please try again.", comment: "Phone auth error message")

        sendCodeButton.isEnabled = false
        sendCodeButton.setTitle(NSLocalizedString("Send code", comment: "Phone auth send code button title"), for: .normal)
        sendCodeButton.addTarget(self, action: #selector(didTapSendCode), for: .touchUpInside)

        let privacyAndTermsTextView = makePrivacyAndTermsTextView()

        let stackView = UIStackView(arrangedSubviews: [
            backButton,
            titleLabel,
            subtitleLabel,
            phoneEnterInputView,
            sendCodeButton,
            privacyAndTermsTextView
        ])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill

        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            phoneEnterInputView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            sendCodeButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            privacyAndTermsTextView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])

        stackView.setCustomSpacing(23, after: backButton)
        stackView.setCustomSpacing(3, after: titleLabel)
        stackView.setCustomSpacing(30, after: subtitleLabel)
        stackView.setCustomSpacing(12, after: phoneEnterInputView)
        stackView.setCustomSpacing(33, after: sendCodeButton)
    }

    private func makePrivacyAndTermsTextView() -> TappableTextView {
        let privacyAndTermsTextView = TappableTextView()

        let termsOfUseText = NSLocalizedString("Terms of Use", comment: "Terms of use text")
        let privacyPolicyText = NSLocalizedString("Privacy Policy", comment: "Privacy policy text")
        let termsAndConditionsTemplate = NSLocalizedString("By continuing you agree to our\n%1$@ and %2$@.", comment: "Terms of use and privacy policy text template")
        let termsAndConditionsText = String(format: termsAndConditionsTemplate, termsOfUseText, privacyPolicyText)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributedString = NSMutableAttributedString(
            string: termsAndConditionsText,
            attributes: [
                .font: UIFont.smallSemibold,
                .foregroundColor: UIColor.stGrey55,
                .paragraphStyle: paragraphStyle
            ])

        let termsOfUseCharacterRange = attributedString.mutableString.range(of: termsOfUseText)
        let privacyPolicyCharacterRange = attributedString.mutableString.range(of: privacyPolicyText)
        [
            termsOfUseCharacterRange: Constants.termsOfUseUrl,
            privacyPolicyCharacterRange: Constants.privacyPolicyUrl
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
            self?.openInWebView(url: url)
        }
        return privacyAndTermsTextView
    }

    private func openInWebView(url: URL) {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        let safariViewController = SFSafariViewController(url: url, configuration: configuration)
        safariViewController.preferredBarTintColor = .stBlack
        safariViewController.preferredControlTintColor = .white
        present(safariViewController, animated: true)
    }
    
    @objc private func didTapSendCode() {
        guard let phone = phoneEnterInputView.textField.text, !phone.isEmpty else { return }
        self.phoneEnterInputView.hideError()

        environment.safeTrace.session.requestAuthenticationCode(for: phone) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if case .success = result {
                    let vc = PhoneVerificationViewController(environment: self.environment, onboardingStep: self.onboardingStep, phone: phone)
                     self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.phoneEnterInputView.textField.setState(.error)
                    self.phoneEnterInputView.showError()
                }
            }
        }
    }
}

extension PhoneEnterViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // hide error label when typing
        phoneEnterInputView.hideError()
        phoneEnterInputView.textField.setState(.focus)

        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        let isValid = isValidNumber(input: updatedText)
        sendCodeButton.isEnabled = isValid
        return true
    }

    private func isValidNumber(input: String?) -> Bool {
        guard let input = input else { return false }
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == input.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSendCode()
        return true
    }
}
