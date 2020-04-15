import Foundation

class TracerEnvironment: Environment {
    lazy var network: NetworkProtocol = Network()
    lazy var session: UserSessionProtocol = UserSession(environment: self)
    let defaults: UserDefaultsProtocol = UserDefaults.standard
    let device = Device()
    let date = { Date() }
}
