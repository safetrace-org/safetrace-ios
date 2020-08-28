import CoreLocation
import Foundation
import ReactiveSwift
import SafeTrace
import UIKit

protocol ReactiveLocationProtocol {
    var current: SignalProducer<CLLocation?, Never> { get }
    var authorizationStatus: SignalProducer<CLAuthorizationStatus, Never> { get }
}

protocol LocationProviding {
    var reactive: ReactiveLocationProtocol { get }
    var currentLocation: CLLocation? { get }
    var currentAuthorization: CLAuthorizationStatus { get }
    func requestAlwaysLocationPermissions()
}

class ReactiveLocation: ReactiveLocationProtocol {
    var current: SignalProducer<CLLocation?, Never>
    var authorizationStatus: SignalProducer<CLAuthorizationStatus, Never>

    fileprivate let _location = MutableProperty<CLLocation?>(nil)
    fileprivate let _authorizationStatus = MutableProperty<CLAuthorizationStatus>(.notDetermined)

    init() {
        current = _location.producer
        authorizationStatus = _authorizationStatus.producer
    }
}

class LocationProvider: NSObject, LocationProviding {

    fileprivate let _reactive = ReactiveLocation()
    fileprivate let locationManager = CLLocationManager()
    fileprivate let decimalPrecision = 5 // 5 is precise to around 1 meter at the equator. More precision just causes unnecessary app updates

    var reactive: ReactiveLocationProtocol {
        return _reactive
    }

    var currentLocation: CLLocation? {
        _reactive._location.value
    }

    var currentAuthorization: CLAuthorizationStatus {
        _reactive._authorizationStatus.value
    }

    override init() {
        super.init()

        locationManager.delegate = self
        _reactive._authorizationStatus.value = CLLocationManager.authorizationStatus()
    }

    func requestAlwaysLocationPermissions() {
        locationManager.requestAlwaysAuthorization()
    }

}

extension LocationProvider: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        _reactive._authorizationStatus.value = status
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.withDecimalPrecision(decimalPrecision) else { return }

        _reactive._location.value = location

        let isInBackground = UIApplication.shared.applicationState == .background
        let locationRequest = LocationRequest(location: location, isBackground: isInBackground)

        SafeTrace.syncLocation(locationRequest)
    }

}

extension LocationRequest {
    init(location: CLLocation, isBackground: Bool) {
        self.init(
            lat: location.coordinate.latitude,
            long: location.coordinate.longitude,
            hAccuracy: location.horizontalAccuracy,
            vAccuracy: location.verticalAccuracy,
            elevation: location.altitude,
            speed: location.speed,
            bearing: location.course,
            background: isBackground)
    }
}
