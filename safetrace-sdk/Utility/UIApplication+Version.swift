import UIKit

extension UIApplication {

    /// Returns a string that describes the app's short version and build number version
    ///
    /// Example: "1.0-2343"
    ///
    /// Where the semantic version and build number are separated by a -
    static var clientApplicationVersionDescription: String {

        let semanticVersion = Bundle
            .main
            .infoDictionary?["CFBundleShortVersionString"] as? String ?? "error"

        let buildNumberVersion = Bundle
            .main
            .infoDictionary?["CFBundleVersion"] as? String ?? "error"

        return "\(semanticVersion)-\(buildNumberVersion)"
    }
    
    static var operatingSystemVersionDescription: String {
        let osVersion = ProcessInfo().operatingSystemVersion
        return "\(osVersion.majorVersion).\(osVersion.minorVersion)"
            + ".\(osVersion.patchVersion)"
    }

    /// Example: "1.1"
    static var clientApplicationVersionShortDescription: String {
        return Bundle
        .main
        .infoDictionary?["CFBundleShortVersionString"] as? String ?? "error"
    }
}
