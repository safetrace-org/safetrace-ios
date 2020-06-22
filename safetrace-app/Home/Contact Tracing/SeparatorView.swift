import UIKit

class SeparatorView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .stGrey10
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
