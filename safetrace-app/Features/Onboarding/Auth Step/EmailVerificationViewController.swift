import ReactiveCocoa
import ReactiveSwift
import SafeTrace
import UIKit

class EmailVerificationViewController: OnboardingViewController {

    private let verificationContext: LoginResponseContext.EmailVerificationData
    private let enterCodeInputView = OnboardingInputView()
    private let resendButton = Button(style: .secondary, size: .small)
    private let needHelpButton = UIButton()

    init(
        environment: Environment,
        verificationContext: LoginResponseContext.EmailVerificationData,
        onboardingStep: OnboardingStep
    ) {
        self.verificationContext = verificationContext
        super.init(environment: environment, onboardingStep: onboardingStep)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .stBlack

        // MARK: - UI Components

        let titleLabel = UILabel()
        titleLabel.font = .titleH2
        titleLabel.textColor = .stBlack
        titleLabel.text = NSLocalizedString("Check your email", comment: "Email verification title")
        titleLabel.textAlignment = .left

        let subtitleLabel = UILabel()
        subtitleLabel.font = .titleH2
        subtitleLabel.textColor = .stGrey55
        subtitleLabel.numberOfLines = 0
        let subtitleTemplate = NSLocalizedString(
            "To log in, you need to verify your account. Enter the code in the email we sent to %@.",
            comment: "Email verification subtitle"
        )
        subtitleLabel.text = String(format: subtitleTemplate, verificationContext.email)
        subtitleLabel.textAlignment = .left

        enterCodeInputView.nameLabel.text = NSLocalizedString("Enter Code", comment: "Email verification code label")
            .uppercased(with: .current)

        enterCodeInputView.textField.keyboardType = .numberPad
        enterCodeInputView.textField.delegate = self

        resendButton.setTitle(
            NSLocalizedString("Resend Email", comment: "Email verification resend email button title")
                .uppercased(with: .current),
            for: .normal
        )
        resendButton.titleLabel?.font = .smallSemibold
        resendButton.addTarget(self, action: #selector(didTapResendButton), for: .touchUpInside)
        resendButton.contentEdgeInsets = .init(top: 0, left: 12, bottom: 0, right: 12)

        needHelpButton.setTitle(
            NSLocalizedString("Need help? Contact Citizen", comment: "Email verification resend button title"),
            for: .normal
        )
        needHelpButton.titleLabel?.font = .smallSemibold
        needHelpButton.setTitleColor(.stBlueMutedUp, for: .normal)
        needHelpButton.setTitleColor(UIColor.stBlueMutedUp.withAlphaComponent(0.8), for: .highlighted)
        needHelpButton.addTarget(self, action: #selector(didTapNeedHelpButton), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            enterCodeInputView,
            resendButton,
            needHelpButton
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill

        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            titleLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            subtitleLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            enterCodeInputView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])

        stackView.setCustomSpacing(3, after: titleLabel)
        stackView.setCustomSpacing(30, after: subtitleLabel)
        stackView.setCustomSpacing(20, after: enterCodeInputView)
        stackView.setCustomSpacing(25, after: resendButton)
    }

    @objc private func didTapResendButton() {
        self.resendButton.setTitle(
            NSLocalizedString("Sending...", comment: "Email verification sending email button title")
                .uppercased(with: .current),
            for: .normal
        )

        environment.safeTrace.session.resendEmailAuthCode(
            phone: verificationContext.phoneNumber,
            deviceID: verificationContext.deviceID
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.resendButton.isEnabled = false
                    self.resendButton.setTitle(
                        NSLocalizedString("Sent", comment: "Email verification successfully re-sent email button title")
                            .uppercased(with: .current),
                        for: .normal
                    )
                case .failure:
                    self.resendButton.isEnabled = true
                    self.resendButton.setTitle(
                        NSLocalizedString("Resend Email", comment: "Email verification resend email button title")
                            .uppercased(with: .current),
                        for: .normal
                    )
                    self.enterCodeInputView.showError(
                        NSLocalizedString("Failed to resend code. Try again.", comment: "Error label when resending email pin failed")
                    )
                }
            }
        }
    }

    @objc private func didTapNeedHelpButton() {
        let webViewController = WebViewController()
        webViewController.loadUrl(Constants.contactCitizenUrl)
        webViewController.modalPresentationStyle = .fullScreen
        present(webViewController, animated: true)
    }

    private func verifyCode(_ code: String) {
        environment.safeTrace.session.authenticateWithEmailCode(code, phone: verificationContext.phoneNumber) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.onboardingStep.stepCompleted()
                case .failure:
                    self.enterCodeInputView.textField.setState(.error)
                    self.enterCodeInputView.showError(
                        NSLocalizedString("Reminder: email pin is not the same as SMS code.", comment: "Error label when entering the wrong email pin")
                    )
                }
            }
        }
    }
}

extension EmailVerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // hide error label when typing
        enterCodeInputView.hideError()
        enterCodeInputView.textField.setState(.focus)

        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        if updatedText.count == 4 {
            verifyCode(updatedText)
        }

        return updatedText.count <= 4
    }
}
