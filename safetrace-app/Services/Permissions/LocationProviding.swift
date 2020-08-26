import CoreLocation
import Foundation
import ReactiveSwift

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
    fileprivate let decimalPrecision = 5


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
        guard let location = locations.last else { return }

        _reactive._location.value = location
    }
}
