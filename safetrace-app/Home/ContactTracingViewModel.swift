import Foundation

struct ContactTracingViewData {
    let contactTracingEnabled: Bool
    let bluetoothDenied: Bool
}

struct ContactTracingViewModel {
    var viewData = ContactTracingViewData(contactTracingEnabled: false, bluetoothDenied: false)

    var updateViewData: ((ContactTracingViewData) -> Void)?

    func setupDefaultViewData() {
        updateViewData?(viewData)
    }
}
