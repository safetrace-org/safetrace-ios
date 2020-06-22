import UIKit

class CitizenUpsellView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        let iconView = UIImageView(image: UIImage(named: "citizenAppIcon")!)
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.font = .bodyLargeBold
        titleLabel.textColor = .stBlue
        titleLabel.text = NSLocalizedString("Get the Citizen app", comment: "Citizen app upsell title")

        let subtitleLabel = UILabel()
        subtitleLabel.font = .smallSemibold
        subtitleLabel.textColor = .stBlueMutedDown
        subtitleLabel.text = NSLocalizedString("The most powerful safety app", comment: "Citizen app upsell subtitle")

        let labelStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel
        ])
        labelStack.axis = .vertical
        labelStack.alignment = .leading
        labelStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [
            iconView,
            labelStack
        ])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 16

        addSubview(mainStack)

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconView.widthAnchor.constraint(equalToConstant: 60),
            iconView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
