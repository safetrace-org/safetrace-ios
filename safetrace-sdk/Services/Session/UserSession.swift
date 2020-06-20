import AdSupport
import Foundation
import WebKit

enum SessionError: Error {
    case notLoggedIn
}

struct AuthData: Codable {
    let uid: String
    let userToken: String
}

private let authTokenKeychainIdentifier = "UserToken"
private let userIDKeychainIdentifier = "UserId"

#if DEV
private let keychainAppIdentifier = "L5262XM8UA.org.ctzn.safetrace-dev"
private let keychainGroupIdentifier = "L5262XM8UA.com.sp0n.vigilantedev"
#else
private let keychainAppIdentifier = "L5262XM8UA.org.ctzn.safetrace"
private let keychainGroupIdentifier = "L5262XM8UA.com.sp0n.vigilante"
#endif

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
        appKeychain: KeychainProtocol = KeychainSwift(accessGroup: keychainAppIdentifier),
        groupKeychain: KeychainProtocol = KeychainSwift(accessGroup: keychainGroupIdentifier)
    ) {
        self.environment = environment
        self.keychain = appKeychain
        attemptToLoadCachedValues()
        
        if !isAuthenticated {
            attemptToLoadValuesFromAppGroup(groupKeychain: groupKeychain)
        }
    }

    func logout() {
        updateStoredValues(token: nil, userID: nil)
        authenticationDelegate?.authenticationStatusDidChange(forSession: self)
    }
    
    func requestAuthenticationCode(for phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
        environment.network.requestAuthCode(phone: phone, completion: completion)
    }

    func authenticateWithCode(_ code: String, phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
        environment.network.authenticateWithCode(code, phone: phone) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let auth):    
                self.authenticate(withUserID: auth.uid, authToken: auth.userToken)
                completion(.success(()))
            }
        }
    }
        
    func authenticateWithToken(_ token: String, userID: String) {
        self.updateStoredValues(token: token, userID: userID)
        self.authenticationDelegate?.authenticationStatusDidChange(forSession: self)
    }
    
    func setAPNSToken(_ token: Data) {
        environment.network.syncPushToken(token, completion: { _ in })
    }
    
    // legacy Citizen auth
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
        authenticationDelegate?.authenticationTokenDidChange(forSession: self)

        DispatchQueue.main.async {
            self.updateAuthTokenWebViewCookie(authToken: self.authToken)
        }
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
        guard let authToken = getCachedAuthToken(from: self.keychain),
            let userID = getCachedUserID(from: self.keychain) else {
            return
        }
        
        updateLocalValues(token: authToken, userID: userID)
    }
    
    // Try to load shared values from Citizen app, if present
    private func attemptToLoadValuesFromAppGroup(groupKeychain: KeychainProtocol) {
        guard let authToken = getCachedAuthToken(from: groupKeychain),
            let userID = getCachedUserID(from: groupKeychain) else {
            return
        }
        
        // Persist values in this app's keychain now that we have them
        updateStoredValues(token: authToken, userID: userID)
    }
    
    private func getCachedAuthToken(from keychain: KeychainProtocol) -> String? {
        return keychain.get(authTokenKeychainIdentifier)
    }
    
    private func getCachedUserID(from keychain: KeychainProtocol) -> String? {
        return keychain.get(userIDKeychainIdentifier)
    }
}

//sourcery: AutoMockable
protocol KeychainProtocol {
    var accessGroup: String? { get set }
    @discardableResult func set(_ value: String, forKey key: String, withAccess: KeychainSwiftAccessOptions?) -> Bool
    func get(_ key: String) -> String?
    @discardableResult func delete(_ key: String) -> Bool
}

extension KeychainSwift: KeychainProtocol { }

extension KeychainSwift {
    convenience init(accessGroup: String?) {
        self.init()
        self.accessGroup = accessGroup
    }
}
