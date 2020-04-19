import UIKit

enum ButtonStyle {
    case primary
    case secondary
}

class Button: UIButton {
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 1, y: 0)
        layer.colors = [
            UIColor.stPurpleGradientStart,
            UIColor.stPurpleGradientMid,
            UIColor.stPurpleGradientEnd
        ].map { $0.cgColor }
        return layer
    }()
    let style: ButtonStyle

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.8 : 1
        }
    }

    init(style: ButtonStyle) {
        self.style = style
        super.init(frame: .zero)

        heightAnchor.constraint(equalToConstant: 48).isActive = true
        layer.cornerRadius = 24
        clipsToBounds = true

        titleLabel?.font = .titleH3

        switch style {
        case .primary:
            setTitleColor(.white, for: .normal)
            layer.insertSublayer(gradientLayer, at: 0)
        case .secondary:
            setTitleColor(.stGrey15, for: .normal)
            layer.borderColor = UIColor.stBlack.withAlphaComponent(0.3).cgColor
            layer.borderWidth = 1
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if style == .primary {
            gradientLayer.frame = self.bounds
        }
    }
}
