import UIKit
import SafeTrace
import WebKit

final class ContactCenterViewController: UIViewController {

    private let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    private let loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)
    private let url = URL(string: Constants.contactCenterUrl)!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Log Out", comment: "Log Out Button Title"),
            style: .plain,
            target: self,
            action: #selector(logout))

        #if STAGING || DEBUG
        navigationItem.setRightBarButton(makeDebugTracingButton(), animated: true)
        #endif

        layoutUI()

        requestWebPage()
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
        let request = URLRequest(url: url)
        webView.load(request)

        loadingIndicator.startAnimating()
    }

    @objc private func logout() {
        SafeTrace.session.logout()

        (navigationController as? MainNavigationController)?.logout()
    }

    @objc private func toggleTracing() {
        if SafeTrace.isTracing {
            SafeTrace.stopTracing()
        } else {
            SafeTrace.startTracing()
        }
        navigationItem.setRightBarButton(makeDebugTracingButton(), animated: true)
    }

    private func makeDebugTracingButton() -> UIBarButtonItem {
        let title = SafeTrace.isTracing ? "Tracing: On" : "Tracing: Off"
        return UIBarButtonItem(
            title: title,
            style: .plain,
            target: self,
            action: #selector(toggleTracing)
        )
    }
}

extension ContactCenterViewController: WKNavigationDelegate, WKUIDelegate {
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
