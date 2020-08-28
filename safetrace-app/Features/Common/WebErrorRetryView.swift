import UIKit

class WebErrorRetryView: UIView {

    var retryHandler: (() -> Void)?

    init() {
        super.init(frame: .zero)

        layoutUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layoutUI() {
        backgroundColor = .stBlack

        let retryIcon = UIImageView(image: UIImage(named: "webRetryIcon"))

        let titleLabel = UILabel()
        titleLabel.textColor = .stWhite
        titleLabel.font = .titleH2
        titleLabel.textAlignment = .center
        titleLabel.text = NSLocalizedString("Something went wrong", comment: "Title for webview retry page")

        let subtitleLabel = UILabel()
        subtitleLabel.textColor = .stGrey70
        subtitleLabel.font = .bodyLargeRegular
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = NSLocalizedString("Content failed to load. Please try again.", comment: "Subtitle for webview retry page")

        let retryButton = Button(style: .primary, size: .large)
        retryButton.setTitle(
            NSLocalizedString("TRY AGAIN", comment: "Button title for webview retry page"),
            for: .normal
        )
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            retryIcon,
            titleLabel,
            subtitleLabel,
            retryButton
        ])
        stackView.axis = .vertical
        stackView.alignment = .center

        stackView.setCustomSpacing(120, after: retryIcon)
        stackView.setCustomSpacing(4, after: titleLabel)
        stackView.setCustomSpacing(90, after: subtitleLabel)

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            retryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            retryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28)
        ])
    }

    @objc private func retryButtonTapped() {
        retryHandler?()
    }
}
