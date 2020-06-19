import Foundation

public enum NetworkEnvironment: String {
    case staging
    case production
    
    internal var safetraceURL: URL {
        switch self {
        case .staging:
            return URL(string: "https://api.staging.ctzn.org")!
        case .production:
            return URL(string: "https://api.ctzn.org")!
        }
    }
    
    internal var sp0nURL: URL {
        switch self {
        case .staging:
            return URL(string: "https://data.staging.sp0n.io")!
        case .production:
            return URL(string: "https://data.sp0n.io")!
        }
    }
}

internal enum Host {
    case safetrace
    case sp0n
    
    func baseURL(for env: NetworkEnvironment) -> URL {
        switch self {
        case .safetrace:
            return env.safetraceURL
        case .sp0n:
            return env.sp0nURL
        }
    }
}

var networkEnvironment: NetworkEnvironment {
    get {
        guard let string = UserDefaults.standard.string(forKey: "org.ctzn.network_environment"),
            let env = NetworkEnvironment(rawValue: string) else {
            
            return .production
        }
        
        return env
    }

    set {
        UserDefaults.standard.set(newValue.rawValue, forKey: "org.ctzn.network_environment")
    }
}

extension URLRequest {
    enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    init(
        endpoint: String,
        method: Method,
        host: Host,
        token: String? = nil,
        body: Encodable? = nil,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .iso8601
    ) throws {
        guard let url = URL(string: endpoint, relativeTo: host.baseURL(for: networkEnvironment)) else {
            preconditionFailure()
        }
        
        self.init(url: url)
        self.httpMethod = method.rawValue
        self.httpBody = try body?.toData(dateEncodingStrategy: dateEncodingStrategy)
        
        if let token = token {
            self.addValue(token, forHTTPHeaderField: "x-access-token")
        }
    }
}

extension Encodable {
    func toData(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = dateEncodingStrategy
        return try encoder.encode(self)
    }
}

enum NetworkError: Error {
    case noData
}

extension URLSession {
    func sendRequest<T: Codable>(
        with request: @autoclosure () throws -> URLRequest,
        resultType: T.Type,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        
        sendRequest(with: request) { result in
            completion(result.flatMap { data in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = dateDecodingStrategy ?? .iso8601
                        let result = try decoder.decode(T.self, from: data)
                        return .success(result)
                    } catch let error {
                        return .failure(error)
                    }
                } else {
                    return .failure(NetworkError.noData)
                }
            })
        }
    }
    
    func sendRequest(
        with request: @autoclosure () throws -> URLRequest,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        sendRequest(with: request) { (result: Result<Data?, Error>) in
            completion(result.map { _ in () })
        }
    }
    
    private func sendRequest(
        with request: () throws -> URLRequest,
        completion: @escaping (Result<Data?, Error>) -> Void
    ) {
        do {
            let r = try request()
            
            dataTask(with: r) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(data))
            }.resume()
        } catch let error {
            completion(.failure(error))
            return
        }
    }
}

extension Result {
    var value: Success? {
        if case .success(let value) = self {
            return value
        }
        
        return nil
    }
    
    var error: Error? {
        if case .failure(let error) = self {
            return error
        }
        
        return nil
    }
}
