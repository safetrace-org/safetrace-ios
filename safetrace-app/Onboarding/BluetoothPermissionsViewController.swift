import SafariServices
import SafeTrace
import UIKit

final class BluetoothPermissionsViewController: OnboardingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appBecameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        // MARK: - UI Components

        let titleLabel = UILabel()
        titleLabel.font = .titleH2
        titleLabel.textColor = .stBlack
        titleLabel.text = NSLocalizedString("Enable Bluetooth", comment: "Bluetooth permissions page title")
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.font = .titleH2
        subtitleLabel.textColor = .stGrey40
        subtitleLabel.text = NSLocalizedString(
            "SafeTrace uses Bluetooth to determine if you have come in nearby contact with someone who has tested positive for COVID-19.",
            comment: "Bluetooth permissions page subtitle"
        )
        subtitleLabel.textAlignment = .left
        subtitleLabel.numberOfLines = 0

        let allowButton = Button(style: .primary)
        allowButton.setTitle(NSLocalizedString("OK", comment: "Bluetooth permissions page allow permissions button title"), for: .normal)
        allowButton.addTarget(self, action: #selector(didTapAllow), for: .touchUpInside)

        let denyButton = Button(style: .secondary)
        denyButton.setTitle(NSLocalizedString("Don't Allow", comment: "Bluetooth permissions page deny permissions button title"), for: .normal)
        denyButton.addTarget(self, action: #selector(didTapDontAllow), for: .touchUpInside)

        let buttonStackView = UIStackView(arrangedSubviews: [
            denyButton,
            allowButton
        ])
        buttonStackView.spacing = 8
        buttonStackView.distribution = .fillEqually

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            buttonStackView
        ])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill

        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 66),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            buttonStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])

        stackView.setCustomSpacing(3, after: titleLabel)
        stackView.setCustomSpacing(33, after: subtitleLabel)
    }

    @objc private func didTapAllow() {
        SafeTrace.startTracing()
    }

    @objc private func didTapDontAllow() {
        // Tell users why we need to have bluetooth permissions
        let alert = UIAlertController(
            title: NSLocalizedString("Bluetooth is required", comment: "Bluetooth permissions alert title"),
            message: NSLocalizedString(
                "SafeTrace uses Bluetooth to determine if you have come in nearby contact with someone who has tested positive for COVID-19.",
                comment: "Bluetooth permissions alert message"
            ),
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    @objc private func appBecameActive() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
        onboardingStep.stepCompleted()
    }
}
