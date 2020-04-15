import Foundation

protocol Environment {
    var network: NetworkProtocol { get }
    var session: UserSessionProtocol { get }
    var defaults: UserDefaultsProtocol { get }
    var device: Device { get }
    var date: () -> Date { get }
}
