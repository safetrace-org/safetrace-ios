import UIKit

class BackButton: UIButton {
    var tapHandler: (() -> Void)?

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.7 : 1
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setImage(UIImage(named: "backIcon"), for: .normal)
        imageView?.contentMode = .scaleAspectFit
        addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        adjustsImageWhenHighlighted = false
        setSize(width: 32, height: 32)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func tappedButton() {
        self.tapHandler?()
    }
}
