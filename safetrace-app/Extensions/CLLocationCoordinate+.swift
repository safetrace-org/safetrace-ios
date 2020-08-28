import CoreLocation
import Foundation

extension CLLocationCoordinate2D {
    func withDecimalPrecision(_ places: Int) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: latitude.roundTo(places: places),
            longitude: longitude.roundTo(places: places)
        )
    }
}

private extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension CLLocation {
    func withDecimalPrecision(_ places: Int) -> CLLocation {
        return CLLocation(
            coordinate: coordinate.withDecimalPrecision(places),
            altitude: altitude,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: verticalAccuracy,
            course: course,
            speed: speed,
            timestamp: timestamp)
    }
}
