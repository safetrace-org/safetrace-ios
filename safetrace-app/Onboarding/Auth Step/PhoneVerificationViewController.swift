import SafeTrace
import UIKit

final class PhoneVerificationViewController: OnboardingViewController {
    private let phone: String
    private let codeTextField = TextField()
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

        let phoneNumberLabel = UILabel()
        phoneNumberLabel.font = .titleH6
        phoneNumberLabel.textColor = .stGrey40
        phoneNumberLabel.text = NSLocalizedString("Enter Code", comment: "Phone veritifcation code label").uppercased(with: Locale.current)
        phoneNumberLabel.textAlignment = .left

        codeTextField.keyboardType = .numberPad
        codeTextField.delegate = self

        resendButton.setTitle(NSLocalizedString("Didn’t receive it? Resend", comment: "Phone verification resend button title"), for: .normal)
        resendButton.titleLabel?.font = .smallSemibold
        resendButton.setTitleColor(.stPurple, for: .normal)
        resendButton.setTitleColor(UIColor.stPurple.withAlphaComponent(0.8), for: .highlighted)
        resendButton.addTarget(self, action: #selector(didTapResendButton), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            backButton,
            titleLabel,
            subtitleLabel,
            phoneNumberLabel,
            codeTextField,
            resendButton
        ])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill

        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        codeTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            codeTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            resendButton.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])

        stackView.setCustomSpacing(23, after: backButton)
        stackView.setCustomSpacing(3, after: titleLabel)
        stackView.setCustomSpacing(30, after: subtitleLabel)
        stackView.setCustomSpacing(8, after: phoneNumberLabel)
        stackView.setCustomSpacing(58, after: codeTextField)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        codeTextField.becomeFirstResponder()
    }

    @objc private func didTapResendButton() {
        goBack()
    }

    private func verifyCode(_ code: String) {
        environment.safeTrace.session.authenticateWithCode(code, phone: phone) { [weak self] result in
            DispatchQueue.main.async {
                if case .success = result {
                    self?.onboardingStep.stepCompleted()
                } else {
                    self?.codeTextField.setState(.error)
                }
            }
        }
    }
}

extension PhoneVerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        if updatedText.count == 4 {
            verifyCode(updatedText)
        }

        return updatedText.count <= 4
    }
}
