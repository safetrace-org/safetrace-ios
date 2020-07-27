import UIKit
import WebKit

final class WebViewController: UIViewController {

    private let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    private let loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)

    var url: URL?

    /// Load a URL
    func loadUrl(_ url: URL) {
        self.url = url

        requestWebPage()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        layoutUI()
    }

    private func layoutUI() {
        view.backgroundColor = .stBlack

        let closeButton = UIButton()
        closeButton.addTarget(self, action: #selector(tapCloseButton), for: .touchUpInside)
        closeButton.setImage(UIImage(named: "closeIcon")!, for: .normal)
        closeButton.accessibilityLabel = NSLocalizedString("Close", comment: "Closes the displayed modal.")
        view.addSubview(closeButton)

        webView.isOpaque = false
        webView.backgroundColor = .stBlack
        webView.scrollView.backgroundColor = .stBlack
        webView.allowsBackForwardNavigationGestures = true

        webView.navigationDelegate = self
        webView.uiDelegate = self

        view.addSubview(webView)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            webView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 12),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var shouldAutorotate: Bool {
        return false
    }

    private func requestWebPage() {
        guard let url = url else {
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)

        loadingIndicator.startAnimating()
    }

    @objc private func tapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
}

extension WebViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.requestWebPage() // retry
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard webView == self.webView else {
            decisionHandler(.allow)
            return
        }

        let application = UIApplication.shared

        guard let url = navigationAction.request.url else {
            return
        }

        if url.scheme == "tel" || url.scheme == "mailto" {
            if application.canOpenURL(url) {
                application.open(url)
            }
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
}
