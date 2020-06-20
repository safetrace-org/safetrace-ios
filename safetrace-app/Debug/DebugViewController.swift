#if INTERNAL
import SafeTrace
import UIKit

internal final class DebugViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
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

        let mainStackView = UIStackView(arrangedSubviews: [
            envStackView,
            debugStackView
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
    
    @objc private func environmentValueChanged(sender: UISegmentedControl) {
        SafeTrace.apiEnvironment = sender.selectedSegmentIndex == 0 ? .staging : .production
        SafeTrace.session.logout()
        fatalError()
    }
    
    @objc private func debugValueChanged(sender: UISwitch) {
        SafeTrace.debug_notificationsEnabled = sender.isOn
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
