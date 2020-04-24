import UIKit

class IntroViewController: OnboardingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)

        // MARK: - UI Components

        let iconView = UIImageView(image: UIImage(named: "introIcon"))
        iconView.contentMode = .scaleAspectFit
        iconView.setSize(width: 88, height: 88)

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 50, weight: .semibold)
        titleLabel.textColor = .stBlack
        titleLabel.text = NSLocalizedString("SafeTrace", comment: "Safetrace intro title")
        titleLabel.textAlignment = .left

        let subtitleLabel = UILabel()
        subtitleLabel.font = .titleH2
        subtitleLabel.textColor = .stGrey40
        subtitleLabel.text = NSLocalizedString("COVID-19 Contact Tracing", comment: "Safetrace intro subtitle")
        subtitleLabel.textAlignment = .left

        let bodyLabel = UILabel()
        bodyLabel.font = .bodyRegular
        bodyLabel.textColor = .stGrey40
        bodyLabel.numberOfLines = 0
        bodyLabel.text = NSLocalizedString("""
        Protect yourself from COVID-19 and help prevent new waves of outbreaks with SafeTrace.

        Start tracing now to get notified if you come into contact with a COVID+ person from today onward.
        """, comment: "Safetrace intro body")
        bodyLabel.textAlignment = .left

        let getStartedButton = Button(style: .primary)
        getStartedButton.setTitle(NSLocalizedString("Get started", comment: "Safetrace intro get started button"), for: .normal)
        getStartedButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            iconView,
            titleLabel,
            subtitleLabel,
            bodyLabel,
            getStartedButton
        ])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill

        view.addSubview(stackView)

        let ctznOrgLogo = UIImageView(image: UIImage(named: "ctznOrgLogo"))
        ctznOrgLogo.contentMode = .scaleAspectFit
        ctznOrgLogo.setSize(width: 149, height: 20)

        view.addSubview(ctznOrgLogo)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        ctznOrgLogo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            getStartedButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: ctznOrgLogo.topAnchor, constant: -16),
            ctznOrgLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ctznOrgLogo.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])

        stackView.setCustomSpacing(15, after: iconView)
        stackView.setCustomSpacing(3, after: titleLabel)
        stackView.setCustomSpacing(32, after: subtitleLabel)
        stackView.setCustomSpacing(35, after: bodyLabel)
    }

    @objc private func didTapButton() {
        navigationController?.pushViewController(
            PhoneEnterViewController(onboardingStep: onboardingStep),
            animated: true
        )
    }
}
