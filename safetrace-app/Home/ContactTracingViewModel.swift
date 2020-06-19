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
    toggleIsOn: Signal<Bool, Never>,
    appBecameActive: Signal<Void, Never>,
    tapDescriptionText: Signal<Void, Never>,
    tapBluetoothPermissionsText: Signal<Void, Never>,
    tapNotificationPermissionsText: Signal<Void, Never>,
    tapPrivacyText: Signal<Void, Never>,
    tapTermsText: Signal<Void, Never>,
    goToSettingsAlertAction: Signal<Void, Never>,
    notificationPermissions: Signal<UNAuthorizationStatus, Never>,
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
        .map { SafeTrace.isOptedIn }
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
        .map { BluetoothPermissions.currentAuthorization }
        .skipRepeats()

    // MARK: - View Data

    let viewData: Signal<ContactTracingViewData, Never> = Signal
        .combineLatest(
            bluetoothPermissions,
            notificationPermissions,
            isOptedIn
        )
        .map { BluetoothPermissions, notificationPermissions, isOptedIn in
            return ContactTracingViewData(
                contactTracingEnabled: isOptedIn,
                bluetoothDenied: notificationPermissions == .denied,
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

    // Open an alert that navigates to app permissions settings if bluetooth permission is denied, only if toggle is turning on
    let toggleOnWhenEitherPermissionsDenied = Signal
        .combineLatest(
            bluetoothPermissions,
            notificationPermissions
        )
        .sample(on: toggleOn)
        .filter { $0 == .denied || $1 == .denied }
        .map(value: ())

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

    let displayAlert: Signal<ContactTracingAlertData, Never> = toggleOnWhenEitherPermissionsDenied
        .map { _ in
            let goToSettingsAction = ContactTracingAlertData.Action(
                title: NSLocalizedString("Go to Settings", comment: "Button title to go to settings to enable bluetooth permissions"),
                style: .default,
                tapAction: ())

            return .init(
                title: NSLocalizedString("Bluetooth and Notifications are required", comment: "Alert title for prompting bluetooth and notification permissions"),
                message: NSLocalizedString(
                    "Citizen uses Bluetooth to determine if you have come in nearby contact with someone who has tested positive for COVID-19.",
                    comment: "Alert message for prompting bluetooth permissions for contact tracing"),
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
