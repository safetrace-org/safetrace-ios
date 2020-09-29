import CoreLocation
import Foundation

//sourcery:AutoMockable
protocol LocationProviding {
    var current: CLLocation? { get }
}

class LocationProvider: LocationProviding {
    private let manager = CLLocationManager()
    
    var current: CLLocation? {
        print("TEST location timestamp: \(String(describing: manager.location?.timestamp))")

        print("TEST location: \(String(describing: manager.location))")
        return manager.location
    }
}
