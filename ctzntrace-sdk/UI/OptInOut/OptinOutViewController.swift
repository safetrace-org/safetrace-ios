import UIKit

internal final class OptInOutViewController: UIViewController {
    private let environment: Environment
    
    init(environment: Environment) {
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        let button = UIButton()
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        button.addTarget(self, action: #selector(logout), for: .touchUpInside)
    }
    
    @objc private func logout() {
        environment.session.logout()
        
        let phoneAuthViewController = PhoneAuthorizationViewController(environment: environment)
        navigationController?.setViewControllers([phoneAuthViewController, self], animated: false)
        navigationController?.popToRootViewController(animated: true)
    }
}
