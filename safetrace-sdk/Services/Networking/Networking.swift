import Foundation

//sourcery:AutoMockable
protocol NetworkProtocol {
    func requestAuthCode(phone: String, completion: @escaping (Result<Void, Error>) -> Void)
    func authenticateWithCode(_ token: String, phone: String, completion: @escaping (Result<AuthData, Error>) -> Void)
    
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
