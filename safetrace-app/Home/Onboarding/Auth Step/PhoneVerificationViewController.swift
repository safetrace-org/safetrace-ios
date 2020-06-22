import SafeTrace
import UIKit

final class PhoneVerificationViewController: OnboardingViewController {
    private let phone: String
    private let enterCodeInputView = OnboardingInputView()
    private let resendButton = UIButton()

    init(environment: Environment, onboardingStep: OnboardingStep, phone: String) {
        self.phone = phone
        super.init(environment: environment, onboardingStep: onboardingStep)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        // MARK: - UI Components

        let backButton = makeBackButton()

        let titleLabel = UILabel()
        titleLabel.font = .titleH2
        titleLabel.textColor = .stBlack
        titleLabel.text = NSLocalizedString("We just sent a code to", comment: "Phone verification title")
        titleLabel.textAlignment = .left

        let subtitleLabel = UILabel()
        subtitleLabel.font = .titleH2
        subtitleLabel.textColor = .stPurple
        subtitleLabel.text = phone
        subtitleLabel.textAlignment = .left

        enterCodeInputView.nameLabel.text = NSLocalizedString("Enter Code", comment: "Phone verification code label").uppercased(with: .current)

        enterCodeInputView.textField.keyboardType = .numberPad
        enterCodeInputView.textField.delegate = self

        enterCodeInputView.errorLabel.text = NSLocalizedString("Invalid Code", comment: "Phone veritifcation code error label")

        resendButton.setTitle(NSLocalizedString("Didn’t receive it? Resend", comment: "Phone verification resend button title"), for: .normal)
        resendButton.titleLabel?.font = .smallSemibold
        resendButton.setTitleColor(.stPurple, for: .normal)
        resendButton.setTitleColor(UIColor.stPurple.withAlphaComponent(0.8), for: .highlighted)
        resendButton.addTarget(self, action: #selector(didTapResendButton), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            backButton,
            titleLabel,
            subtitleLabel,
            enterCodeInputView,
            resendButton
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
            enterCodeInputView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            resendButton.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])

        stackView.setCustomSpacing(23, after: backButton)
        stackView.setCustomSpacing(3, after: titleLabel)
        stackView.setCustomSpacing(30, after: subtitleLabel)
        stackView.setCustomSpacing(30, after: enterCodeInputView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        enterCodeInputView.textField.becomeFirstResponder()
    }

    @objc private func didTapResendButton() {
        goBack()
    }

    private func verifyCode(_ code: String) {
        environment.safeTrace.session.authenticateWithCode(code, phone: phone) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let context):
                    switch context {
                    case .loginSuccess:
                        self.onboardingStep.stepCompleted()
                    case .requiresEmailVerification(let emailVerificationContext):
                        let emailVerificationViewController = EmailVerificationViewController(
                            environment: self.environment,
                            verificationContext: emailVerificationContext,
                            onboardingStep: self.onboardingStep
                        )
                        self.navigationController?.pushViewController(emailVerificationViewController, animated: true)
                    }
                case .failure:
                    self.enterCodeInputView.textField.setState(.error)
                    self.enterCodeInputView.showError()
                }
            }
        }
    }
}

extension PhoneVerificationViewController: UITextFieldDelegate {
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
