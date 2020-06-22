import UIKit

protocol CitizenProviding {
    var isInstalled: Bool { get }
    func open()
}

struct CitizenProvider: CitizenProviding {
    var isInstalled: Bool {
        let url = Constants.citizenDeeplinkUrl
        return UIApplication.shared.canOpenURL(url)
    }

    func open() {
        let url = isInstalled
            ? Constants.citizenDeeplinkUrl
            : Constants.citizenAppStoreLink

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
