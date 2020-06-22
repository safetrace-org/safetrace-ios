import UIKit

class TextField: UITextField {

    enum State {
        case error
        case focus
        case none
    }

    private let errorIconView = UIImageView(image: UIImage(named: "errorX")!)
    private var currentState: State = .none

    override init(frame: CGRect) {
        super.init(frame: .zero)

        backgroundColor = .stGrey10
        textAlignment = .left
        textColor = .stWhite
        layer.borderWidth = 1
        layer.cornerRadius = 12
        tintColor = .stPurpleAccentUp
        autocorrectionType = .no
        isHighlighted = false

        errorIconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(errorIconView)
        setState(.none)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 48.0),
            errorIconView.widthAnchor.constraint(equalToConstant: 24),
            errorIconView.heightAnchor.constraint(equalToConstant: 24),
            errorIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            errorIconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setState(_ state: State) {
        switch state {
        case .none:
            layer.borderColor = UIColor.stGrey25.cgColor
            errorIconView.isHidden = true
        case .focus:
            layer.borderColor = UIColor.stPurple.cgColor
            errorIconView.isHidden = true
        case .error:
            layer.borderColor = UIColor.stRed.cgColor
            errorIconView.isHidden = false
        }
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        let becomeFirstResponder = super.becomeFirstResponder()
        setState(becomeFirstResponder ? .focus : .none)
        return becomeFirstResponder
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        let resignFirstResponder = super.resignFirstResponder()
        setState(resignFirstResponder ? .none : .focus)
        return resignFirstResponder
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let systemBounds = super.textRect(forBounds: bounds)
        return systemBounds.insetBy(dx: 16.0, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let systemBounds = super.editingRect(forBounds: bounds)
        return systemBounds.insetBy(dx: 16.0, dy: 0)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        // placeholders by default are pushed in, by requesting the textRect
        // it lines up perfectly with where the text will go
        let systemBounds = super.textRect(forBounds: bounds)
        return systemBounds.insetBy(dx: 16.0, dy: 0)
    }
}
