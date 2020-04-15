import Foundation

let baseURL = URL(string: "https://data.staging.sp0n.io")!

extension URLRequest {
    enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    init(endpoint: String, method: Method, body: Encodable? = nil) throws {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            preconditionFailure()
        }
        
        self.init(url: url)
        self.httpMethod = method.rawValue
        self.httpBody = try body?.toData()
    }
}

extension Encodable {
    func toData() throws -> Data {
        let encoder = JSONEncoder()
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
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        
        sendRequest(with: request) { result in
            completion(result.flatMap { data in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
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
