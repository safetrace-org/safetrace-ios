import Foundation

//sourcery:AutoMockable
protocol NetworkProtocol {
    func requestAuthCode(phone: String, completion: @escaping (Result<Void, Error>) -> Void)
    func authenticateWithCode(_ token: String, phone: String, completion: @escaping (Result<AuthData, Error>) -> Void)
    
    func getTraceIDs(userID: String, completion: @escaping (Result<[TraceIDRecord], Error>) -> Void)
    func uploadTraces(_: ContactTraces, userID: String, completion: @escaping (Result<Void, Error>) -> Void)
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
        struct Wrapper: Codable {
            let traces: [TraceIDRecord]
        }
        
        urlSession.sendRequest(
            with: try URLRequest(
                endpoint: "v1/users/\(userID)/traces",
                method: .get,
                token: environment.session.authToken),
            resultType: Wrapper.self,
            dateDecodingStrategy: .secondsSince1970,
            completion: {
                completion($0.map { $0.traces })
            }
        )
    }

    func uploadTraces(_ traces: ContactTraces, userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        urlSession.sendRequest(
            with: try URLRequest(
                endpoint: "v1/users/\(userID)/traces",
                method: .post,
                token: environment.session.authToken,
                body: traces,
                dateEncodingStrategy: .iso8601),
            completion:completion)
    }
}
