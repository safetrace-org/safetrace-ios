import UIKit

class IntroViewController: OnboardingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .stBlack
        navigationController?.setNavigationBarHidden(true, animated: false)

        // MARK: - UI Components

        let iconView = UIImageView(image: UIImage(named: "introIcon"))
        iconView.contentMode = .scaleAspectFit
        iconView.setSize(width: 80, height: 80)

        let titleLabel = UILabel()
        titleLabel.font = .titleH2
        titleLabel.textColor = .stWhite
        titleLabel.numberOfLines = 0
        titleLabel.text = NSLocalizedString("Welcome to Citizen SafePass", comment: "SafePass intro title")
        titleLabel.textAlignment = .left

        let subtitleLabel = UILabel()
        subtitleLabel.font = .titleH2
        subtitleLabel.textColor = .stGrey70
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = NSLocalizedString("Your SafePass is your hub for COVID-19 symptom tracking, testing sites, and contact tracing so you and your friends can stay safe.", comment: "Safepass intro subtitle")
        subtitleLabel.textAlignment = .left

        let getStartedButton = Button(style: .primary)
        getStartedButton.setTitle(NSLocalizedString("Get started", comment: "Safepass intro get started button"), for: .normal)
        getStartedButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            iconView,
            titleLabel,
            subtitleLabel
        ])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill

        view.addSubview(stackView)
        view.addSubview(getStartedButton)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        getStartedButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            getStartedButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            getStartedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getStartedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])

        stackView.setCustomSpacing(24, after: iconView)
        stackView.setCustomSpacing(3, after: titleLabel)
    }

    @objc private func didTapButton() {
        navigationController?.pushViewController(
            PhoneEnterViewController(environment: environment, onboardingStep: onboardingStep),
             animated: true
        )
    }
}
