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
        titleLabel.text = NSLocalizedString("Welcome to Citizen SafeTrace", comment: "Safetrace intro title")
        titleLabel.textAlignment = .left

        let subtitleLabel = UILabel()
        subtitleLabel.font = .titleH2
        subtitleLabel.textColor = .stGrey70
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = NSLocalizedString("Get notified when you’ve been in contact with someone who tests positive with COVID-19.", comment: "Safetrace intro subtitle")
        subtitleLabel.textAlignment = .left

        let getStartedButton = Button(style: .primary)
        getStartedButton.setTitle(NSLocalizedString("Get started", comment: "Safetrace intro get started button"), for: .normal)
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
