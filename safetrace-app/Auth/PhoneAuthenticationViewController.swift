import SafeTrace
import UIKit

internal final class PhoneAuthenticationViewController: UIViewController {
    private let textField = UITextField()
    private let submitButton = UIButton()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        submitButton.setTitle("Submit Phone #", for: .normal)
        submitButton.setTitleColor(.systemBlue, for: .normal)
        textField.backgroundColor = .lightGray
        textField.textAlignment = .center
        
        let stackView = UIStackView()
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(submitButton)
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            textField.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        textField.delegate = self
        submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
    }
    
    @objc private func submit() {
        guard let phone = textField.text, !phone.isEmpty else { return }
        
        SafeTrace.session.requestAuthenticationCode(for: phone) { result in
            DispatchQueue.main.async {
                if case .success = result {
                    let vc = ConfirmationCodeViewController(phone: phone)
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    // TODO: display error state
                }
            }
        }
    }
}

extension PhoneAuthenticationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submit()
        return true
    }
}
