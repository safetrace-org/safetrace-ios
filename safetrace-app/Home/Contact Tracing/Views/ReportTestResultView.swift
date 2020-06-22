import UIKit

class ReportTestResultView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .stGrey10
        layer.masksToBounds = true
        layer.cornerRadius = 12

        let iconView = UIImageView(image: UIImage(named: "reportTestResultIcon")!)
        iconView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.font = .titleH3
        label.textColor = .stBlue
        label.text = NSLocalizedString("Report a test result", comment: "Report test result button title")

        let buttonStack = UIStackView(arrangedSubviews: [
            iconView,
            label
        ])
        buttonStack.axis = .vertical
        buttonStack.alignment = .leading
        buttonStack.spacing = 14
        buttonStack.layoutMargins = .init(top: 24, left: 20 , bottom: 24, right: 40)
        buttonStack.isLayoutMarginsRelativeArrangement = true

        let chevron = UIImageView(image: UIImage(named: "rightChevron")!)

        addSubview(buttonStack)
        addSubview(chevron)

        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        chevron.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonStack.topAnchor.constraint(equalTo: topAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),

            chevron.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
