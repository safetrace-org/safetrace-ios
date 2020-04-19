import SafeTrace
import UIKit

final class PhoneEnterViewController: OnboardingViewController {
    private let phoneTextField = TextField()
    private let sendCodeButton = Button(style: .primary)
    
    init() {
        super.init(nibName: nil, bundle: nil)
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
        titleLabel.text = NSLocalizedString("Enter your phone number", comment: "Phone auth title")
        titleLabel.textAlignment = .left

        let subtitleLabel = UILabel()
        subtitleLabel.font = .titleH2
        subtitleLabel.textColor = .stGrey40
        subtitleLabel.text = NSLocalizedString("to sign up or log in.", comment: "Phone auth subtitle")
        subtitleLabel.textAlignment = .left

        let phoneNumberLabel = UILabel()
        phoneNumberLabel.font = .titleH6
        phoneNumberLabel.textColor = .stGrey40
        phoneNumberLabel.text = NSLocalizedString("Phone Number", comment: "Phone auth phone number label").uppercased(with: Locale.current)
        phoneNumberLabel.textAlignment = .left

        phoneTextField.keyboardType = .numberPad
        phoneTextField.delegate = self

        sendCodeButton.isEnabled = false
        sendCodeButton.setTitle(NSLocalizedString("Send code", comment: "Phone auth send code button title"), for: .normal)
        sendCodeButton.addTarget(self, action: #selector(didTapSendCode), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            backButton,
            titleLabel,
            subtitleLabel,
            phoneNumberLabel,
            phoneTextField,
            sendCodeButton
        ])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill

        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        phoneTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            phoneTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            sendCodeButton.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])

        stackView.setCustomSpacing(23, after: backButton)
        stackView.setCustomSpacing(30, after: subtitleLabel)
        stackView.setCustomSpacing(8, after: phoneNumberLabel)
        stackView.setCustomSpacing(40, after: phoneTextField)
    }
    
    @objc private func didTapSendCode() {
        guard let phone = phoneTextField.text, !phone.isEmpty else { return }

        SafeTrace.session.requestAuthenticationCode(for: phone) { [weak self] result in
            DispatchQueue.main.async {
                if case .success = result {
                    let vc = ConfirmationCodeViewController(phone: phone)
                    self?.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self?.phoneTextField.setState(.error)
                }
            }
        }
    }
}

extension PhoneEnterViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isValid = isValidNumber(input: textField.text)
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
