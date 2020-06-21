import Foundation
import ReactiveSwift
import SafeTrace
import UserNotifications

struct ContactTracingViewData {
    let contactTracingEnabled: Bool
    let bluetoothDenied: Bool
    let notificationDenied: Bool
}

typealias ContactTracingAlertData = AlertData<Void>

func contactTracingViewModel(
    environment: Environment,
    toggleIsOn: Signal<Bool, Never>,
    appBecameActive: Signal<Void, Never>,
    notificationPermissionsChanged: Signal<UNAuthorizationStatus, Never>,
    tapDescriptionText: Signal<Void, Never>,
    tapBluetoothPermissionsText: Signal<Void, Never>,
    tapNotificationPermissionsText: Signal<Void, Never>,
    tapPrivacyText: Signal<Void, Never>,
    tapTermsText: Signal<Void, Never>,
    goToSettingsAlertAction: Signal<Void, Never>,
    viewDidLoad: Signal<Void, Never>
) -> (
    viewData: Signal<ContactTracingViewData, Never>,
    optIn: Signal<Void, Never>,
    optOut: Signal<Void, Never>,
    askBluetoothPermissions: Signal<Void, Never>,
    askNotificationPermissions: Signal<Void, Never>,
    navigateToAppSettings: Signal<Void, Never>,
    openWebView: Signal<URL, Never>,
    displayAlert: Signal<ContactTracingAlertData, Never>
) {
    let optInPipe = Signal<Bool, Never>.pipe()

    // MARK: - Opt In Status

    let isInitiallyOptedIn = viewDidLoad
        .map { environment.safeTrace.isOptedIn }
    let isOptedIn = Signal
        .merge(
            isInitiallyOptedIn,
            optInPipe.output
        )
        .skipRepeats()

    // MARK: - Bluetooth Permissions

    let bluetoothPermissions = Signal
        .merge(
            viewDidLoad,
            appBecameActive
        )
        .map { environment.bluetoothPermissions.currentAuthorization }
        .skipRepeats()

    // MARK: - Notification Permissions

    let notificationPermissions = Signal
        .merge(
            viewDidLoad,
            appBecameActive
        )
        .flatMap(.latest) { _ -> SignalProducer<UNAuthorizationStatus, Never> in
            SignalProducer<UNAuthorizationStatus, Never> { completion in
                environment.notificationPermissions.getCurrentAuthorization { status in
                    completion(status)
                }
            }
        }
        .merge(with: notificationPermissionsChanged)
        .skipRepeats()

    // MARK: - View Data

    let viewData: Signal<ContactTracingViewData, Never> = Signal
        .combineLatest(
            bluetoothPermissions,
            notificationPermissions,
            isOptedIn
        )
        .map { bluetoothPermissions, notificationPermissions, isOptedIn in
            return ContactTracingViewData(
                contactTracingEnabled: isOptedIn,
                bluetoothDenied: bluetoothPermissions == .denied,
                notificationDenied: notificationPermissions == .denied
            )
        }

    // MARK: - Handle Toggle Tap

    // Tapping the highlighted description text will turn on the toggle too
    // If the toggle was in off position
    let tapDescriptionTextToTurnOn = isOptedIn
        .sample(on: tapDescriptionText)
        .filter { !$0 }

    let toggleChanged = Signal
        .merge(
            toggleIsOn,
            tapDescriptionTextToTurnOn.map(value: true)
        )
    let toggleOn = toggleChanged.filter { $0 }.map(value: ())
    let toggleOff = toggleChanged.filter { !$0 }.map(value: ())

    let askBluetoothPermissions = bluetoothPermissions
        .sample(on: toggleOn)
        .filter { $0 == .notDetermined }
        .map(value: ())

    let toggledOnAndAskedBluetooth = Signal
        .combineLatest(
            toggleOn,
            bluetoothPermissions
        )
        .filter { $1 != .notDetermined }
        .map(value: ())

    let askNotificationPermissions = notificationPermissions
        .sample(on: toggledOnAndAskedBluetooth)
        .filter { $0 == .notDetermined }
        .map(value: ())

    let toggleOnWhenPermissionsDenied = Signal
        .combineLatest(
            bluetoothPermissions,
            notificationPermissions
        )
        .sample(on: toggleOn)
        .compactMap { bluetoothPermissions, notificationPermissions -> PermissionsAlertCopy? in
            if bluetoothPermissions == .denied && notificationPermissions == .denied {
                return .missingBoth
            } else if bluetoothPermissions == .denied {
                return .missingBluetooth
            } else if notificationPermissions == .denied {
                return .missingNotification
            }
            return nil
        }

    let tapBluetoothPermissionTextWhenDenied = bluetoothPermissions
        .sample(on: tapBluetoothPermissionsText)
        .filter { $0 == .denied }
        .map(value: ())

    let tapNotificationPermissionTextWhenDenied = notificationPermissions
        .sample(on: tapNotificationPermissionsText)
        .filter { $0 == .denied }
        .map(value: ())

    let navigateToAppSettings = Signal.merge(
        goToSettingsAlertAction,
        tapBluetoothPermissionTextWhenDenied,
        tapNotificationPermissionTextWhenDenied
    )

    let displayAlert: Signal<ContactTracingAlertData, Never> = toggleOnWhenPermissionsDenied
        .map { alertCopy in
            let goToSettingsAction = ContactTracingAlertData.Action(
                title: NSLocalizedString("Go to Settings", comment: "Button title to go to settings to enable permissions"),
                style: .default,
                tapAction: ())

            return .init(
                title: alertCopy.title,
                message: alertCopy.message,
                actions: [goToSettingsAction, .cancel]
            )
        }

    // MARK: - Opting in and out

    let optIn = toggleOn
    let optOut = toggleOff

    toggleChanged
        .observe(optInPipe.input)

    // MARK: - Web Views

    let openPrivacyWebView = tapPrivacyText
        .map(value: URL(string: "https://citizen.com/tracing/privacy")!)

    let openTermsWebView = tapTermsText
        .map(value: URL(string: "https://citizen.com/tracing/terms")!)

    let openWebView = Signal.merge(
        openPrivacyWebView,
        openTermsWebView
    )

    return (
        viewData: viewData,
        optIn: optIn,
        optOut: optOut,
        askBluetoothPermissions: askBluetoothPermissions,
        askNotificationPermissions: askNotificationPermissions,
        navigateToAppSettings: navigateToAppSettings,
        openWebView: openWebView,
        displayAlert: displayAlert
    )
}

private enum PermissionsAlertCopy {
    case missingBluetooth
    case missingNotification
    case missingBoth

    var title: String {
        switch self {
        case .missingBluetooth:
            return NSLocalizedString("Bluetooth is required", comment: "Alert title for prompting bluetooth permissions")
        case .missingNotification:
            return NSLocalizedString("Notifications is required", comment: "Alert title for prompting notification permissions")
        case .missingBoth:
            return NSLocalizedString("Bluetooth and Notifications are required", comment: "Alert title for prompting both bluetooth and notification permissions")
        }
    }

    var message: String {
        switch self {
        case .missingBluetooth:
            return NSLocalizedString(
                "Citizen SafeTrace uses Bluetooth to provide COVID-19 contact tracing and exposure notifications.",
                comment: "Alert message for prompting bluetooth permissions for contact tracing"
            )
        case .missingNotification:
            return NSLocalizedString(
                "Citizen SafeTrace uses Notifications to provide COVID-19 contact tracing and exposure notifications.",
                comment: "Alert message for prompting notification permissions for contact tracing"
            )
        case .missingBoth:
            return NSLocalizedString(
                "Citizen SafeTrace uses Bluetooth and Notifications to provide COVID-19 contact tracing and exposure notifications.",
                comment: "Alert message for prompting both bluetooth and notification permissions for contact tracing"
            )
        }
    }
}
