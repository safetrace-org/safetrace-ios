import Foundation
import WebKit

class WebViewHelper {
    /// List of domains for which we will
    /// 1. Sync authorized cookies
    /// 2. Expose javascript messageHandler to
    private static let authorizedDomains = [
        "sp0n.io",
        "citizen.com"
    ]

    static func isAuthorizedDomain(url: URL) -> Bool {
        guard let host = url.host else {
            return false
        }
        return authorizedDomains.contains(where: { matchesTopLevelDomain(host: host, domain: $0) })
    }

    private static func matchesTopLevelDomain(host: String, domain: String) -> Bool {
        let dottedDomain = "." + domain
        return host == domain || host.hasSuffix(dottedDomain)
    }

    /// Starts the loading of given URL, and returns a `WebViewController` instance in the `launchHandler` block.
    static func launchWebViewController(
        url: URL,
        showCloseButton: Bool,
        environment: Environment,
        launchHandler: @escaping (WebViewController) -> Void
    ) {
        environment.safeTrace.session.syncAuthTokenWebviewCookies() {
            // Sync cookies again before launching webViewController, especially on simulator cookies may not have synced during app launch
            let webViewController = WebViewController(environment: environment, showCloseButton: showCloseButton)
            webViewController.loadUrl(url)
            launchHandler(webViewController)
        }
    }

}
