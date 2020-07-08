import Analytics
import Foundation

protocol AnalyticsTracking {
    func track(event: String, params: [String: Any])
}

internal final class AnalyticsTracker: AnalyticsTracking {
    init() {
        configure()
    }
    
    func track(event: String, params: [String: Any]) {
        Analytics.shared().track(event, properties: params)
    }

    private func configure() {
        let analyticsConfiguration: AnalyticsConfiguration
        
        #if INTERNAL
        analyticsConfiguration = AnalyticsConfiguration(writeKey: "org.ctzn.safetrace-dev")
        analyticsConfiguration.flushAt = 1
        #else
        analyticsConfiguration = AnalyticsConfiguration(writeKey: "org.ctzn.safetrace")
        #endif
        
        analyticsConfiguration.requestFactory = { url in
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.host = "metrics.sp0n.io"
            
            guard let url = components?.url else {
                fatalError("Failed to get URL from segAnalyticsConfiguration")
            }
            
            return NSMutableURLRequest(url: url)
        }
        
        Analytics.setup(with: analyticsConfiguration)
        Analytics.shared().flush()
    }

}
