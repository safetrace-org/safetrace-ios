import UIKit

class TappableView: UIView {
    let gestureRecognizer: UITapGestureRecognizer

    override init(frame: CGRect) {
        gestureRecognizer = UITapGestureRecognizer()
        super.init(frame: frame)

        addGestureRecognizer(gestureRecognizer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
