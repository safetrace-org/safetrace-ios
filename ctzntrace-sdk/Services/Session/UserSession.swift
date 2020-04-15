import AdSupport
import Foundation
import WebKit

enum SessionError: Error {
    case notLoggedIn
}

struct AuthData: Codable {
    let userID: String
    let authToken: String
}

private let authTokenKeychainIdentifier = "org.ctzn.auth_token"
private let userIDKeychainIdentifier = "org.ctzn.userID"

class UserSession: UserSessionProtocol {    
    weak var authenticationDelegate: UserSessionAuthenticationDelegate?
    
    var isAuthenticated: Bool {
        return authToken != nil
    }

    private(set) var userID: String?
    private(set) var authToken: String?
    
    private let environment: Environment
    private let keychain: KeychainProtocol
    
    init(
        environment: Environment,
        keychain: KeychainProtocol = KeychainSwift()
    ) {
        self.environment = environment
        self.keychain = keychain
        attemptToLoadCachedValues()
    }
        
    func logout() {
        updateStoredValues(token: nil, userID: nil)
        authenticationDelegate?.authenticationStatusDidChange(forSession: self)
    }
    
    func authenticateWithToken(_ token: String, phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
        environment.network.authenticateWithToken(token, phone: phone) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let auth):
                self.authenticate(withUserID: auth.userID, authToken: auth.authToken)
                completion(.success(()))
            }
        }
    }
        
    private func authenticate(withUserID userID: String, authToken: String) {
        self.updateStoredValues(token: authToken, userID: userID)
        self.authenticationDelegate?.authenticationStatusDidChange(forSession: self)
    }
    
    private func updateStoredValues(token: String?, userID: String?) {
        if let token = token {
            keychain.set(token, forKey: authTokenKeychainIdentifier, withAccess: .accessibleAfterFirstUnlockThisDeviceOnly)
        }
        
        if let userID = userID {
            keychain.set(userID, forKey: userIDKeychainIdentifier, withAccess: .accessibleAfterFirstUnlock)
        }
        
        updateLocalValues(token: token, userID: userID)
    }
    
    private func updateLocalValues(token: String?, userID: String?) {
        self.userID = userID
        self.authToken = token

        updateAuthTokenWebViewCookie(authToken: authToken)
        authenticationDelegate?.authenticationTokenDidChange(forSession: self)
    }

    private func updateAuthTokenWebViewCookie(authToken: String?) {
        let authorizedDomains = [
            "staging.sp0n.io",
            "citizen.com"
        ]
        for domain in authorizedDomains {
            guard let cookie = HTTPCookie(properties: [
                .domain: domain,
                .path: "/",
                .name: "citizen:auth:token",
                .value: authToken ?? "",
                .secure: "TRUE",
                .expires: Date(timeIntervalSinceNow: 86400) // cookie expires in one day
            ]) else {
                assertionFailure("Cannot create cookie for authToken host: \(domain)")
                return
            }
            WKWebsiteDataStore.default().httpCookieStore.setCookie(cookie)
        }
    }
    
    private func attemptToLoadCachedValues() {
        // we want to have *both* or *neither* to be in a consistent state
        guard let authToken = getCachedAuthToken(),
              let userID = getCachedUserID() else {
            return
        }
        
        updateLocalValues(token: authToken, userID: userID)
    }
    
    private func getCachedAuthToken() -> String? {
        return keychain.get(authTokenKeychainIdentifier)
    }
    
    private func getCachedUserID() -> String? {
        return keychain.get(userIDKeychainIdentifier)
    }
}

//sourcery: AutoMockable
protocol KeychainProtocol {
    @discardableResult func set(_ value: String, forKey key: String, withAccess: KeychainSwiftAccessOptions?) -> Bool
    func get(_ key: String) -> String?
    @discardableResult func delete(_ key: String) -> Bool
}

extension KeychainSwift: KeychainProtocol { }
