import CoreLocation
import Foundation

//sourcery:AutoMockable
protocol LocationProviding {
    var current: CLLocation? { get }
}

class LocationProvider: LocationProviding {
    private let manager = CLLocationManager()
    
    var current: CLLocation? {
        return manager.location
    }
}
