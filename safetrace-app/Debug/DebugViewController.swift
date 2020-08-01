#if INTERNAL
import SafeTrace
import UIKit

internal final class DebugViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)

        navigationItem.rightBarButtonItem = .init(title: "Close", style: .plain, target: self, action: #selector(dismissVC))

        let envSwitch = UISegmentedControl()
        envSwitch.insertSegment(withTitle: "Staging", at: 0, animated: false)
        envSwitch.insertSegment(withTitle: "Production", at: 1, animated: false)
        envSwitch.selectedSegmentIndex = SafeTrace.apiEnvironment == .staging ? 0 : 1
        
        if #available(iOS 13, *) {
            envSwitch.selectedSegmentTintColor = .stPurple
        }
        
        envSwitch.addTarget(self, action: #selector(environmentValueChanged(sender:)), for: .valueChanged)
        
        let envLabel = UILabel()
        envLabel.text = "Environment: "
        envLabel.textColor = .black
        
        let envStackView = UIStackView(arrangedSubviews: [
            envLabel,
            envSwitch
        ])

        let debugSwitch = UISwitch()
        debugSwitch.isOn = SafeTrace.debug_notificationsEnabled
        debugSwitch.addTarget(self, action: #selector(debugValueChanged(sender:)), for: .valueChanged)
        
        let debugLabel = UILabel()
        debugLabel.text = "Debug Notifications: "
        debugLabel.textColor = .black
        
        let debugStackView = UIStackView(arrangedSubviews: [
            debugLabel,
            debugSwitch
        ])

        let logoutButton = Button(style: .secondary, size: .small)
        logoutButton.contentEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)

        let debuggerButton = Button(style: .primary, size: .small)
        debuggerButton.contentEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
        debuggerButton.setTitle("🔵 Bluetooth Debugger", for: .normal)
        debuggerButton.addTarget(self, action: #selector(openBluetoothDebugger), for: .touchUpInside)

        let healthCheckDebuggerButton = Button(style: .primary, size: .small)
        healthCheckDebuggerButton.contentEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
        healthCheckDebuggerButton.setTitle("❤️ Health Check Debugger", for: .normal)
        healthCheckDebuggerButton.addTarget(self, action: #selector(openHealthCheckDebugger), for: .touchUpInside)

        let mainStackView = UIStackView(arrangedSubviews: [
            envStackView,
            debugStackView,
            logoutButton,
            debuggerButton,
            healthCheckDebuggerButton
        ])
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.alignment = .center
        mainStackView.spacing = 10
        
        view.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        
        view.backgroundColor = .white
    }

    @objc private func dismissVC() {
        dismiss(animated: true)
    }
    
    @objc private func environmentValueChanged(sender: UISegmentedControl) {
        SafeTrace.apiEnvironment = sender.selectedSegmentIndex == 0 ? .staging : .production
        SafeTrace.session.logout()
        fatalError()
    }
    
    @objc private func debugValueChanged(sender: UISwitch) {
        SafeTrace.debug_notificationsEnabled = sender.isOn
    }

    @objc private func logout() {
        SafeTrace.session.logout()
        fatalError()
    }

    @objc private func openBluetoothDebugger() {
        let vc = BluetoothDebugViewController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true, completion: nil)
    }

    @objc private func openHealthCheckDebugger() {
        let vc = HealthCheckDebugViewController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true, completion: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
