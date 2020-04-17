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
        
        let tracingLabel = UILabel()
        tracingLabel.text = "Enable Tracing: "
        tracingLabel.textColor = .black
        
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(toggleBluetooth(sender:)), for: .valueChanged)
        toggle.isOn = CTZNTrace.shared.isTracing

        let switchStackView = UIStackView(arrangedSubviews: [
            tracingLabel,
            toggle
        ])
        
        let debugLabel = UILabel()
        debugLabel.text = "Enable Debug Notifs: "
        debugLabel.textColor = .black
        
        let notifToggle = UISwitch()
        notifToggle.addTarget(self, action: #selector(toggleNotifs(sender:)), for: .valueChanged)
        notifToggle.isOn = Debug.notificationsEnabled

        let notifStackView = UIStackView(arrangedSubviews: [
            debugLabel,
            notifToggle
        ])

        let button = UIButton()
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)

        let stackView = UIStackView(arrangedSubviews: [
            switchStackView,
            notifStackView,
            button
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        toggle.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        
        button.addTarget(self, action: #selector(logout), for: .touchUpInside)
    }
    
    @objc private func logout() {
        environment.session.logout()
        
        let phoneAuthViewController = PhoneAuthorizationViewController(environment: environment)
        navigationController?.setViewControllers([phoneAuthViewController, self], animated: false)
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func toggleBluetooth(sender: UISwitch) {
        if sender.isOn {
            CTZNTrace.shared.tracer.optIn()
        } else {
            CTZNTrace.shared.tracer.optOut()
        }
    }
    
    @objc private func toggleNotifs(sender: UISwitch) {
        Debug.notificationsEnabled = sender.isOn
    }
}
