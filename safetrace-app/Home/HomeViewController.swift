import UIKit
import SafeTrace

internal final class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        let tracingLabel = UILabel()
        tracingLabel.text = "Enable Tracing: "
        tracingLabel.textColor = .black
        
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(toggleBluetooth(sender:)), for: .valueChanged)
        toggle.isOn = SafeTrace.isTracing

        let switchStackView = UIStackView(arrangedSubviews: [
            tracingLabel,
            toggle
        ])
        
        let debugLabel = UILabel()
        debugLabel.text = "Enable Debug Notifs: "
        debugLabel.textColor = .black
        
        let notifToggle = UISwitch()
        notifToggle.addTarget(self, action: #selector(toggleNotifs(sender:)), for: .valueChanged)
        notifToggle.isOn = SafeTrace.debug_notificationsEnabled

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
        SafeTrace.session.logout()
        
        let introViewController = IntroViewController()
        navigationController?.setViewControllers([introViewController, self], animated: false)
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func toggleBluetooth(sender: UISwitch) {
        if sender.isOn {
            SafeTrace.startTracing()
        } else {
            SafeTrace.stopTracing()
        }
    }
    
    @objc private func toggleNotifs(sender: UISwitch) {
        SafeTrace.debug_notificationsEnabled = sender.isOn
    }
}
