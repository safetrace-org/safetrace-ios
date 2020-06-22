import Foundation
import ReactiveSwift
import SafeTrace
import UserNotifications

struct ContactTracingViewData {
    enum TracingStatus {
        case defaultDisabled
        case enabled
        case error
    }

    let isOptedIn: Bool
    let tracingStatus: TracingStatus
    let bluetoothDenied: Bool
    let notificationDenied: Bool
    let isCitizenInstalled: Bool
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
    tapLearnMoreButton: Signal<Void, Never>,
    tapReportTestResult: Signal<Void, Never>,
    tapCitizenUpsell: Signal<Void, Never>,
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
    openCitizenAppOrAppStore: Signal<Void, Never>,
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

    // MARK: - Is Citizen Installed

    let isCitizenInstalled = Signal
        .merge(
            viewDidLoad,
            appBecameActive
        )
        .map { environment.citizen.isInstalled }
        .skipRepeats()

    // MARK: - View Data

    let viewData: Signal<ContactTracingViewData, Never> = Signal
        .combineLatest(
            bluetoothPermissions,
            notificationPermissions,
            isOptedIn,
            isCitizenInstalled
        )
        .map { bluetoothPermissions, notificationPermissions, isOptedIn, isCitizenInstalled in
            let tracingStatus: ContactTracingViewData.TracingStatus
            if !isOptedIn {
                tracingStatus = .defaultDisabled
            } else if bluetoothPermissions == .denied || notificationPermissions == .denied {
                tracingStatus = .error
            } else {
                tracingStatus = .enabled
            }

            return ContactTracingViewData(
                isOptedIn: isOptedIn,
                tracingStatus: tracingStatus,
                bluetoothDenied: bluetoothPermissions == .denied,
                notificationDenied: notificationPermissions == .denied,
                isCitizenInstalled: isCitizenInstalled
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
        .map(value: Constants.privacyPolicyUrl)

    let openTermsWebView = tapTermsText
        .map(value: Constants.termsOfUseUrl)

    let openHowItWorksWebView = tapLearnMoreButton
        .map(value: Constants.contactTracingLearnMoreUrl)

    let openReportTestResultWebView = tapReportTestResult
        .map(value: Constants.reportTestResultUrl)

    let openWebView = Signal.merge(
        openPrivacyWebView,
        openTermsWebView,
        openHowItWorksWebView,
        openReportTestResultWebView
    )

    return (
        viewData: viewData,
        optIn: optIn,
        optOut: optOut,
        askBluetoothPermissions: askBluetoothPermissions,
        askNotificationPermissions: askNotificationPermissions,
        navigateToAppSettings: navigateToAppSettings,
        openWebView: openWebView,
        openCitizenAppOrAppStore: tapCitizenUpsell,
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
