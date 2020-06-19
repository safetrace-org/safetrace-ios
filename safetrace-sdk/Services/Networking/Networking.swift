import UIKit

//sourcery:AutoMockable
protocol NetworkProtocol {
    func requestAuthCode(phone: String, completion: @escaping (Result<Void, Error>) -> Void)
    func authenticateWithCode(_ token: String, phone: String, completion: @escaping (Result<AuthData, Error>) -> Void)
    
    func setTracingEnabled(_ enabled: Bool, userID: String, completion: @escaping (Result<Void, Error>) -> Void)
    func syncPushToken(_ token: Data, completion: @escaping (Result<Void, Error>) -> Void)
    func sendHealthCheck(
        userID: String,
        bluetoothEnabled: Bool,
        notificationsEnabled: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func getTraceIDs(userID: String, completion: @escaping (Result<[TraceIDRecord], Error>) -> Void)
    func uploadTraces(_ traces: ContactTraces, userID: String, completion: @escaping (Result<Void, Error>) -> Void)
}

struct Network: NetworkProtocol {
    private let environment: Environment
    private let urlSession: URLSession = .shared
    
    init(environment: Environment) {
        self.environment = environment
    }

    // MARK: - Auth
    func requestAuthCode(phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
        urlSession.sendRequest(
            with: try URLRequest(
                endpoint: "v1/auth/request_code",
                method: .post,
                host: .sp0n,
                token: environment.session.authToken,
                body: [
                    "phoneNumber": phone
                ]),
            completion: completion)
    }

    func authenticateWithCode(_ code: String, phone: String, completion: @escaping (Result<AuthData, Error>) -> Void) {
        urlSession.sendRequest(
            with: try URLRequest(
                endpoint: "v1/auth/validate_code",
                method: .post,
                host: .sp0n,
                token: environment.session.authToken,
                body: [
                    "phoneNumber": phone,
                    "code": code
                ]),
            resultType: AuthData.self,
            completion: completion)
    }
    
    // MARK: - Permissions Sync
    func setTracingEnabled(_ enabled: Bool, userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        struct SettingPayload: Encodable {
            let setting_name: String
            let setting_status: Bool
        }
        
        urlSession.sendRequest(
            with: try URLRequest(
                endpoint: "v1/users/\(userID)/settings",
                method: .post,
                host: .sp0n,
                token: environment.session.authToken,
                body: SettingPayload(
                    setting_name: "contact_tracing_enabled",
                    setting_status: enabled
                )), completion: completion)
    }
    
    func syncPushToken(_ token: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        struct TokenPayload: Encodable {
            let appVersion: String
            let osVersion: String
            let deviceType: String
            let deviceToken: String
            let deviceTokenTs: TimeInterval
        }
        
        urlSession.sendRequest(
            with: try URLRequest(
                endpoint: "v1/users/subscribe_device",
                method: .post,
                host: .sp0n,
                token: environment.session.authToken,
                body: TokenPayload(
                    appVersion: UIApplication.clientApplicationVersionDescription,
                    osVersion: UIApplication.operatingSystemVersionDescription,
                    deviceType: "IOS",
                    deviceToken: token.hexStringRepresentation,
                    deviceTokenTs: Date().timeIntervalSince1970 * 1000)
            ), completion: completion)
    }
    
    func sendHealthCheck(
        userID: String,
        bluetoothEnabled: Bool,
        notificationsEnabled: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        urlSession.sendRequest(
            with: try URLRequest(
                endpoint: "v1/sidecar/users/\(userID)/active",
                method: .post,
                host: .sp0n, token: environment.session.authToken,
                body: [
                    "notifications_enabled": notificationsEnabled,
                    "bluetooth_enabled": bluetoothEnabled
                ]), completion: completion)
    }

    // MARK: - Trace
    func getTraceIDs(userID: String, completion: @escaping (Result<[TraceIDRecord], Error>) -> Void) {
        urlSession.sendRequest(
            with: try URLRequest(
                endpoint: "v1/trace_ids",
                method: .get,
                host: .safetrace,
                token: environment.session.authToken),
            resultType: [TraceIDRecord].self,
            dateDecodingStrategy: .secondsSince1970,
            completion: completion)
    }
    
    func uploadTraces(_ traces: ContactTraces, userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        urlSession.sendRequest(
            with: try URLRequest(
                endpoint: "v1/traces",
                method: .post,
                host: .safetrace,
                token: environment.session.authToken,
                body: traces,
                dateEncodingStrategy: .iso8601),
            completion:completion)
    }
}
