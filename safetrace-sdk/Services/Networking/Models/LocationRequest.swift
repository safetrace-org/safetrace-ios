import Foundation

public struct LocationRequest: Codable {
    public let latitude: Double
    public let longitude: Double
    public let horizontalAccuracy: Double
    public let verticalAccuracy: Double
    public let elevation: Double
    public let speed: Double
    public let bearing: Double
    public let background: Bool
    
    public init(
        lat: Double,
        long: Double,
        hAccuracy: Double,
        vAccuracy: Double,
        elevation: Double,
        speed: Double,
        bearing: Double,
        background: Bool
    ) {
        self.latitude = lat
        self.longitude = long
        self.horizontalAccuracy = hAccuracy
        self.verticalAccuracy = vAccuracy
        self.elevation = elevation
        self.speed = speed
        self.bearing = bearing
        self.background = background
    }
}
