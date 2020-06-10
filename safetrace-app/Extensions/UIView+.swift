import UIKit

extension UIView {
    func setSize(width: CGFloat, height: CGFloat) {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: height)
        ])
    }
}
