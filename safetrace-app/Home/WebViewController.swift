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
        webView.isOpaque = false
        webView.backgroundColor = .stBlack
        webView.scrollView.backgroundColor = .stBlack
        webView.allowsBackForwardNavigationGestures = true

        webView.navigationDelegate = self
        webView.uiDelegate = self

        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
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
