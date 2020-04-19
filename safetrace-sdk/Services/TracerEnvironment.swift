import Foundation

class TracerEnvironment: Environment {
    lazy var tracer = ContactTracer(environment: self)
    lazy var network: NetworkProtocol = Network(environment: self)
    lazy var session: UserSessionProtocol = UserSession(environment: self)
    lazy var traceIDs: TraceIDStorageProtocol = TraceIDStorage(environment: self)

    let defaults: UserDefaultsProtocol = UserDefaults.standard
    let device = Device()
    let date = { Date() }
    
    init() {
        
    }
}

extension TracerEnvironment: UserSessionAuthenticationDelegate {
    func authenticationStatusDidChange(forSession: UserSessionProtocol) {
        if !session.isAuthenticated {
            tracer.optOut()
            traceIDs.clear()
        }
    }
    
    func authenticationTokenDidChange(forSession: UserSessionProtocol) {
        //
    }
}
