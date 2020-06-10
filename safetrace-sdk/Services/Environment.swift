import Foundation

protocol Environment {
    var tracer: ContactTracer { get }
    var network: NetworkProtocol { get }
    var session: UserSessionProtocol { get }
    var defaults: UserDefaultsProtocol { get }
    var traceIDs: TraceIDStorageProtocol { get }
    var location: LocationProviding { get }
    var device: Device { get }
    var date: () -> Date { get }
}
