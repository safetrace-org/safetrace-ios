import Foundation

//sourcery: AutoMockable
protocol UserDefaultsProtocol {
    func set(_: Any?, forKey: String)
    func object(forKey: String) -> Any?
    func data(forKey: String) -> Data?
    func bool(forKey: String) -> Bool
}

extension UserDefaults: UserDefaultsProtocol { }
