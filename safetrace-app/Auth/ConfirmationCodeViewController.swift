import SafeTrace
import UIKit

final class ConfirmationCodeViewController: UIViewController {
    private let phone: String
    
    private let textField = UITextField()
    private let submitButton = UIButton()
    
    init(phone: String) {
        self.phone = phone
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        submitButton.setTitle("Submit Confirmation Code", for: .normal)
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
        guard let text = textField.text, !text.isEmpty else { return }
        
        SafeTrace.session.authenticateWithCode(text, phone: phone) { result in
            DispatchQueue.main.async {
                if case .success = result {
                    let vc = HomeViewController()
                    self.navigationController?.setViewControllers([vc], animated: true)
                } else {
                    // TODO: display error state
                }
            }
        }
    }
}

extension ConfirmationCodeViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        submit()
    }
}
