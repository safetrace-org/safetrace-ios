import SafariServices
import SafeTrace
import UIKit

final class BluetoothRequiredViewController: OnboardingViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)

        // MARK: - UI Components

        let titleLabel = UILabel()
        titleLabel.font = .titleH2
        titleLabel.textColor = .stBlack
        titleLabel.text = NSLocalizedString("Bluetooth Required", comment: "Bluetooth required page title")
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.font = .titleH2
        subtitleLabel.textColor = .stGrey40
        subtitleLabel.text = NSLocalizedString(
            "SafeTrace requires Bluetooth to determine if you have come in nearby contact with someone who has tested positive for COVID-19.",
            comment: "Bluetooth required page subtitle"
        )
        subtitleLabel.textAlignment = .left
        subtitleLabel.numberOfLines = 0

        let goToSettingsButton = Button(style: .primary)
        goToSettingsButton.setTitle(NSLocalizedString("Turn on in Settings", comment: "Bluetooth required page go to settings button title"), for: .normal)
        goToSettingsButton.addTarget(self, action: #selector(goToSettings), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            goToSettingsButton
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
            goToSettingsButton.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])

        stackView.setCustomSpacing(3, after: titleLabel)
        stackView.setCustomSpacing(33, after: subtitleLabel)
    }

    @objc private func goToSettings() {
        guard
            let settingsUrl = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl)
        else {
            return
        }

        UIApplication.shared.open(settingsUrl, completionHandler: nil)
    }
}
