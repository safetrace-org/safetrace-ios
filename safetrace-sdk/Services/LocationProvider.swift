import CoreLocation
import Foundation

//sourcery:AutoMockable
protocol LocationProviding {
    var current: CLLocation? { get }
}

class LocationProvider: LocationProviding {
    private let manager = CLLocationManager()
    
    var current: CLLocation? {
        print("TEST location timestampe: \(String(describing: manager.location?.timestamp))")
        return manager.location
    }
}
