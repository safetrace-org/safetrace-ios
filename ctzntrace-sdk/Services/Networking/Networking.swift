import Foundation

//sourcery:AutoMockable
protocol NetworkProtocol {
    func sendAuthToken(phone: String, completion: @escaping (Result<Void, Error>) -> Void)
    func authenticateWithToken(_ token: String, phone: String, completion: @escaping (Result<AuthData, Error>) -> Void)
    
    func getTraceIDs(userID: String, completion: @escaping (Result<[TraceIDRecord], Error>) -> Void)
}

struct Network: NetworkProtocol {
    let urlSession: URLSession = .shared
    
    // MARK: - Auth
    func sendAuthToken(phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
        urlSession.sendRequest(
            with: try URLRequest(
                endpoint: "PHONE PHONE PHONE",
                method: .post),
            completion: completion)
    }

    func authenticateWithToken(_ token: String, phone: String, completion: @escaping (Result<AuthData, Error>) -> Void) {
        urlSession.sendRequest(
            with: try URLRequest(
                endpoint: "PHONE PHONE PHONE",
                method: .post),
            resultType: AuthData.self,
            completion: completion)
    }
    
    // MARK: - Trace IDs
    func getTraceIDs(userID: String, completion: @escaping (Result<[TraceIDRecord], Error>) -> Void) {
        struct Wrapper: Codable {
            let traceIDs: [TraceIDRecord]
        }
        
        urlSession.sendRequest(
            with: try URLRequest(
                endpoint: "v1/users/\(userID)/traces",
                method: .get),
            resultType: Wrapper.self,
            completion: {
                completion($0.map { $0.traceIDs })
            }
        )
    }
}
