import UIKit

protocol CitizenProviding {
    var isInstalled: Bool { get }
    func openSafepass()
}

struct CitizenProvider: CitizenProviding {
    var isInstalled: Bool {
        let url = Constants.citizenDeeplinkUrl
        return UIApplication.shared.canOpenURL(url)
    }

    func openSafepass() {
        let url = isInstalled
            ? Constants.citizenSafepassDeeplinkUrl
            : Constants.citizenAppStoreLink

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
