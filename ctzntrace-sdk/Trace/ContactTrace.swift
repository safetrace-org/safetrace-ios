import CoreLocation
import Foundation

public struct ContactTrace: Codable {
    public struct Location: Codable {
        public let latitude: Double
        public let longitude: Double
        public let horizontalAccuracy: Double
        public let verticalAccuracy: Double
        public let elevation: Double
        public let speed: Double
        public let bearing: Double
    }

    public struct Receiver: Codable {
        public let timestamp: Date
        public let location: Location?
        public let foreground: Bool

        public init(timestamp: Date, location: Location?, foreground: Bool) {
            self.timestamp = timestamp
            self.location = location
            self.foreground = foreground
        }
    }

    public struct Sender: Codable {
        public let foreground: Bool
        public let signalStrength: Double
        public let phoneModel: String
        public let traceID: String

        public init(
            foreground: Bool,
            signalStrength: Double,
            phoneModel: String,
            traceID: String
        ) {
            self.foreground = foreground
            self.signalStrength = signalStrength
            self.phoneModel = phoneModel
            self.traceID = traceID
        }
    }

    public let sender: Sender
    public let receiver: Receiver

    public init(sender: Sender, receiver: Receiver) {
        self.sender = sender
        self.receiver = receiver
    }
}

public struct ContactTraces: Codable {
    public let traces: [ContactTrace]
    public let phoneModel: String

    public init(traces: [ContactTrace], phoneModel: String) {
        self.traces = traces
        self.phoneModel = phoneModel
    }
}

public extension ContactTrace.Location {
    init?(_ location: CLLocation?) {
        guard let location = location else { return nil }

        self.init(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            horizontalAccuracy: location.horizontalAccuracy,
            verticalAccuracy: location.verticalAccuracy,
            elevation: location.altitude,
            speed: location.speed,
            bearing: location.course)
    }
}
