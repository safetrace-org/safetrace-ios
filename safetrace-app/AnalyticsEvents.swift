import Foundation

protocol AnalyticsEvent: RawRepresentable where RawValue == String {}

struct AnyEvent: AnalyticsEvent {
    let rawValue: String
    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

enum SystemAnalytic: String, AnalyticsEvent {
    case appLaunch = "app_launch"
    case appForeground = "app_foreground"
    case appBackground = "app_background"
    case appTerminated = "app_terminated"
}

enum TracingAnalytic: String, AnalyticsEvent {
    case traceError = "trace_error"
}
