import AdSupport
import Foundation
import WebKit

enum SessionError: Error {
    case notLoggedIn
}

struct AuthData: Codable {
    enum CodingKeys: String, CodingKey {
        case userId = "uid"
        case userToken
        case email
        case errorMessageToDisplay = "message"
        case isLogin = "registered"
    }

    public let isLogin: Bool?
    // These two sent together on success
    public let userId: String?
    public let userToken: String?
    // These two sent together if needs to validate email
    public let email: String?
    public let errorMessageToDisplay: String?
}

public enum LoginResponseContext {
    public struct EmailVerificationData {
        public let email: String
        public let phoneNumber: String
        public let deviceID: String?
    }

    case loginSuccess
    case requiresEmailVerification(EmailVerificationData)
}

private let authTokenKeychainIdentifier = "UserToken"
private let userIDKeychainIdentifier = "UserId"

#if INTERNAL
private let keychainAppIdentifier = "L5262XM8UA.org.ctzn.safetrace-dev"
private let keychainGroupIdentifier = "L5262XM8UA.com.sp0n.vigilantedev"
#else
private let keychainAppIdentifier = "L5262XM8UA.org.ctzn.safetrace"
private let keychainGroupIdentifier = "L5262XM8UA.com.sp0n.vigilante"
#endif

class UserSession: UserSessionProtocol {
    
    weak var authenticationDelegate: UserSessionAuthenticationDelegate?
    var userIDDidChange: ((_ userID: String?) -> Void)?
    
    var isAuthenticated: Bool {
        return authToken != nil
    }

    var isCitizenAuthenticated: Bool {
        guard
            let _ = getCachedAuthToken(from: groupKeychain),
            let _ = getCachedUserID(from: groupKeychain)
        else {
            return false
        }
        return true
    }

    private(set) var userID: String?
    private(set) var authToken: String?
    
    private let environment: Environment
    private let keychain: KeychainProtocol
    private let groupKeychain: KeychainProtocol
    
    init(
        environment: Environment,
        appKeychain: KeychainProtocol = KeychainSwift(accessGroup: keychainAppIdentifier),
        groupKeychain: KeychainProtocol = KeychainSwift(accessGroup: keychainGroupIdentifier)
    ) {
        self.environment = environment
        self.keychain = appKeychain
        self.groupKeychain = groupKeychain

        setFirstTimeDefaultIfNeeded()
        attemptToLoadCachedValues()

        if !isAuthenticated {
            attemptToLoadValuesFromAppGroup(groupKeychain: groupKeychain)
        }
    }

    func logout() {
        SafeTrace.stopTracing()

        updateStoredValues(token: nil, userID: nil)
        authenticationDelegate?.authenticationStatusDidChange(forSession: self)
    }
    
    func requestAuthenticationCode(for phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
        environment.network.requestAuthCode(phone: phone, completion: completion)
    }

    func authenticateWithCode(_ code: String, phone: String, completion: @escaping (Result<LoginResponseContext, Error>) -> Void) {
        let adManager = ASIdentifierManager.shared()
        let deviceID: String? = adManager.isAdvertisingTrackingEnabled ? adManager.advertisingIdentifier.uuidString : nil

        environment.network.authenticateWithCode(code, phone: phone, deviceID: deviceID) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let auth):
                if let emailToVerify = auth.email {
                    completion(.success(
                        .requiresEmailVerification(
                            .init(
                                email: emailToVerify,
                                phoneNumber: phone,
                                deviceID: deviceID
                            )
                        )
                    ))
                } else if let userId = auth.userId, let userToken = auth.userToken {
                    self.authenticate(withUserID: userId, authToken: userToken)
                    completion(.success(.loginSuccess))
                } else {
                    completion(.failure(SessionError.notLoggedIn))
                }
            }
        }
    }

    func authenticateWithEmailCode(_ code: String, phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
        environment.network.authenticateWithEmailCode(code, phone: phone) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let auth):
                if let userId = auth.userId, let userToken = auth.userToken {
                    self.authenticate(withUserID: userId, authToken: userToken)
                    completion(.success(()))
                } else {
                    completion(.failure(SessionError.notLoggedIn))
                }
            }
        }
    }

    func resendEmailAuthCode(phone: String, deviceID: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        environment.network.resendEmailAuthCode(phone: phone, deviceID: deviceID, completion: completion)
    }
    
    func setAPNSToken(_ token: Data) {
        environment.network.syncPushToken(token, completion: { _ in })
    }

    private func authenticate(withUserID userID: String, authToken: String) {
        self.updateStoredValues(token: authToken, userID: userID)
        self.authenticationDelegate?.authenticationStatusDidChange(forSession: self)
    }

    private func updateStoredValues(token: String?, userID: String?) {
        if let token = token {
            keychain.set(token, forKey: authTokenKeychainIdentifier, withAccess: .accessibleAfterFirstUnlock)
        } else {
            keychain.delete(authTokenKeychainIdentifier)
        }
        
        if let userID = userID {
            keychain.set(userID, forKey: userIDKeychainIdentifier, withAccess: .accessibleAfterFirstUnlock)
        } else {
            keychain.delete(userIDKeychainIdentifier)
        }
        
        updateLocalValues(token: token, userID: userID)
    }
    
    private func updateLocalValues(token: String?, userID: String?) {
        self.userID = userID
        self.authToken = token
        self.authenticationDelegate?.authenticationTokenDidChange(forSession: self)
        self.userIDDidChange?(userID)

        updateAuthTokenWebViewCookies(authToken: token)
    }

    func updateAuthTokenWebViewCookies(authToken: String?) {
        DispatchQueue.main.async {
            let authorizedCookieDict = [
                ".sp0n.io": "citizen:auth:token",
                ".citizen.com": "citizen:auth:token",
                ".thesafetrace.org": "safetrace:auth:token"
            ]
            let dataStore = WKWebsiteDataStore.default()

            if let authToken = authToken {
                for (domain, cookieName) in authorizedCookieDict {
                    guard let cookie = HTTPCookie(properties: [
                        .domain: domain,
                        .path: "/",
                        .name: cookieName,
                        .value: authToken,
                        .secure: "TRUE",
                        .expires: Date(timeIntervalSinceNow: 31536000) // cookie expires in one year
                    ]) else {
                        assertionFailure("Cannot create cookie for authToken host: \(domain)")
                        return
                    }
                    dataStore.httpCookieStore.setCookie(cookie)
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
            } else {
                // Clear all web data
                // From https://gist.github.com/insidegui/4a5de215a920885e0f36294d51263a15
                dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                    records.forEach { record in
                        dataStore.removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                    }
                }
            }
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

    /// Since we save userID and token on keychain, it's persisted even if app is deleted
    private func setFirstTimeDefaultIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: "org.ctzn.firstInstall") else { return }

        UserDefaults.standard.set(true, forKey: "org.ctzn.firstInstall")
        logout()
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
