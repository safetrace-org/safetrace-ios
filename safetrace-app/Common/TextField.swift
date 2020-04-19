import UIKit

class TextField: UITextField {

    enum State {
        case error
        case focus
        case none
    }

    var currentState: State = .none

    override init(frame: CGRect) {
        super.init(frame: .zero)

        backgroundColor = .stGrey90
        textAlignment = .left
        layer.borderWidth = 1
        layer.cornerRadius = 12
        tintColor = .stPurple
        autocorrectionType = .no
        isHighlighted = false
        setState(.none)

        heightAnchor.constraint(equalToConstant: 48.0).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setState(_ state: State) {
        switch state {
        case .none:
            layer.borderColor = UIColor.stGrey70.cgColor
        case .focus:
            layer.borderColor = UIColor.stPurple.cgColor
        case .error:
            layer.borderColor = UIColor.stRed.cgColor
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
