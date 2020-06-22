import UIKit

class OnboardingInputView: UIStackView {
    let nameLabel = UILabel()
    let textField = TextField()
    let errorLabel = UILabel()

    init() {
        super.init(frame: .zero)

        nameLabel.font = .titleH6
        nameLabel.textColor = .stGrey40
        nameLabel.textAlignment = .left

        errorLabel.font = .smallSemibold
        errorLabel.textColor = .stRed
        errorLabel.alpha = 0
        errorLabel.numberOfLines = 0
        errorLabel.text = ""

        addArrangedSubview(nameLabel)
        addArrangedSubview(textField)
        addArrangedSubview(errorLabel)

        axis = .vertical
        alignment = .fill
        distribution = .fill

        setCustomSpacing(8, after: nameLabel)
        setCustomSpacing(4, after: textField)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showError(_ errorText: String? = nil) {
        errorLabel.alpha = 1
        if let errorText = errorText {
            errorLabel.text = errorText
        }
    }

    func hideError() {
        errorLabel.alpha = 0
    }
}
