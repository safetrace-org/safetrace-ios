import UIKit

internal final class AppSwitcherOverlayViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let left = UIImage(named: "DoNotCloseLeft")
        let right = UIImage(named: "DoNotCloseRight")
        let center = UIImage(named: "DoNotCloseCenter")

        let leftView = UIImageView(image: left)
        let rightView = UIImageView(image: right)
        let centerView = UIImageView(image: center)
        
        leftView.translatesAutoresizingMaskIntoConstraints = false
        rightView.translatesAutoresizingMaskIntoConstraints = false
        centerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(leftView)
        view.addSubview(rightView)
        view.addSubview(centerView)
        
        NSLayoutConstraint.activate([
            leftView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            rightView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rightView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.backgroundColor = .init(white: 0.0, alpha: 0.7)
    }
}
