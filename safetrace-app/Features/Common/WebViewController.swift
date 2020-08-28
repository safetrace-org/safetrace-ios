import UIKit
import WebKit

final class WebViewController: UIViewController {
    var webViewConfiguration: WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "contactTracing")
        userContentController.add(self, name: "user")
        userContentController.add(self, name: "webView")
        userContentController.add(self, name: "deepLink")
        config.userContentController = userContentController

        return config
    }

    private lazy var webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
    private let loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)
    private let errorOverlay = WebErrorRetryView()

    private let environment: Environment
    private let showCloseButton: Bool

    var url: URL?

    init(environment: Environment, showCloseButton: Bool) {
        self.environment = environment
        self.showCloseButton = showCloseButton

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

        navigationController?.setNavigationBarHidden(true, animated: false)

        let stackView = UIStackView()
        stackView.axis = .vertical

        view.addSubview(stackView)

        // Close Button
        let closeButtonContainerView = UIView()
        let closeButton = UIButton()
        closeButton.addTarget(self, action: #selector(tapCloseButton), for: .touchUpInside)
        closeButton.setImage(UIImage(named: "closeIcon")!, for: .normal)
        closeButton.accessibilityLabel = NSLocalizedString("Close", comment: "Closes the displayed modal.")

        closeButtonContainerView.addSubview(closeButton)
        stackView.addArrangedSubview(closeButtonContainerView)

        closeButtonContainerView.isHidden = !showCloseButton

        // WebView

        webView.isOpaque = false
        webView.backgroundColor = .stBlack
        webView.scrollView.backgroundColor = .stBlack
        webView.allowsBackForwardNavigationGestures = true

        webView.navigationDelegate = self
        webView.uiDelegate = self

        stackView.addArrangedSubview(webView)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            closeButton.topAnchor.constraint(equalTo: closeButtonContainerView.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: closeButtonContainerView.trailingAnchor, constant: -20),
            closeButton.bottomAnchor.constraint(equalTo: closeButtonContainerView.bottomAnchor, constant: -12),

            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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

    fileprivate func showErrorOverlay(retryUrl: URL?, errorCode: Int, errorDomain: String) {
        loadingIndicator.stopAnimating()
        errorOverlay.removeFromSuperview()

        errorOverlay.retryHandler = { [weak self] in
            self?.requestWebPage()
            self?.loadingIndicator.startAnimating()
        }
        webView.addSubview(errorOverlay)

        errorOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorOverlay.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            errorOverlay.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            errorOverlay.topAnchor.constraint(equalTo: webView.topAnchor),
            errorOverlay.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
        ])

        if let currentUrl = retryUrl {
            self.url = currentUrl
        }
    }
}

extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        guard let messageUrl = message.webView?.url, WebViewHelper.isAuthorizedDomain(url: messageUrl) else {
            SLog.print("Unauthorized webview interface. Message body: \(message.body)")
            return
        }

        guard let body = message.body as? String else {
            SLog.print("Unexpected message body for \"\(message.name)\": \(message.body)")
            return
        }

        switch message.name {
        case "contactTracing":
            if body == "getOptInStatus" {
                let isOptedIn = environment.safeTrace.isOptedIn
                let javascriptToRun: String = "_tracing.setOptedInStatus(\(isOptedIn))"
                runJavaScript(javascriptToRun)
            } else if body == "openOptInPage" {
                presentContactTracingController()
            } else if body == "getIsCitizenInstalled" {
                let citizenURL = Constants.citizenDeeplinkUrl
                let isCitizenInstalled = UIApplication.shared.canOpenURL(citizenURL)

                let javascriptToRun: String = "_tracing.setIsCitizenInstalled(\(isCitizenInstalled))"
                runJavaScript(javascriptToRun)
            } else if body == "optInToTracing" {
                environment.safeTrace.startTracing()
            }
        case "user":
//            if body == "getLocation" {
//                let javascriptToRun: String
//                if let currentLocation = environment.location.current {
//                    javascriptToRun = "_user.setLocation({'lat': \(currentLocation.coordinate.latitude), 'long': \(currentLocation.coordinate.longitude)})"
//                } else {
//                    javascriptToRun = "_user.setLocation(null)"
//                }
//                runJavaScript(javascriptToRun)
//            } else

            if body == "getAppVersion" {
                let appVersion = Bundle
                    .main
                    .infoDictionary?["CFBundleShortVersionString"] as? String ?? "error"
                let javascriptToRun = "_user.setAppVersion('\(appVersion)')"
                runJavaScript(javascriptToRun)
            } else if body == "goToSettings" {
                environment.bluetoothPermissions.openSettings()
            }
        case "webView":
            presentWebViewWithURLString(urlString: body)
        case "deepLink":
            guard
                let url = URL(string: body),
                UIApplication.shared.canOpenURL(url)
            else {
                return
            }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        default:
            break
        }
    }

    private func runJavaScript(_ script: String) {
        webView.evaluateJavaScript(script) { _, error in
            guard let error = error else { return }
            SLog.print(error)
        }
    }

    private func presentContactTracingController() {
        let viewController = ContactTracingViewController(environment: environment, showCloseButton: true)
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }

    private func presentWebViewWithURLString(urlString: String) {
        if let url = URL(string: urlString) {
            let webViewController = WebViewController(environment: environment, showCloseButton: true)
            webViewController.loadUrl(url)
            webViewController.modalPresentationStyle = .fullScreen
            present(webViewController, animated: true)
        }
    }
}

extension WebViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let error = error as NSError
        if error.code == NSURLErrorCancelled {
            // Happens when a resource load was cancelled. This does not indicate that the page failed to load
            return
        }
        SLog.print("Error: Failed to request URL for web view. \(error) ")

        showErrorOverlay(retryUrl: webView.url, errorCode: error.code, errorDomain: error.domain)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let error = error as NSError
        if error.code == NSURLErrorCancelled {
            // Happens when another request is made before the previous request is completed. This does not indicate that the page failed to load
            return
        }
        SLog.print(error)

        showErrorOverlay(retryUrl: webView.url, errorCode: error.code, errorDomain: error.domain)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        errorOverlay.removeFromSuperview()
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
