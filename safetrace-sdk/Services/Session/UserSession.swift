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

public struct User: Codable {
    public var email: String?
    public var firstName: String?
    public var lastName: String?
    public var avatarURL: URL?
    public var avatarThumbURL: URL?
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
private let userProfileKeychainIdentifer = "UserProfile"

func getKeychains() -> (app: KeychainProtocol, group: KeychainProtocol) {
    let keychainAppIdentifier: String
    let keychainGroupIdentifier: String
    
    let bundleID = Bundle.main.bundleIdentifier
    if bundleID?.hasSuffix("-dev") ?? false {
        keychainAppIdentifier = "L5262XM8UA.org.ctzn.safetrace-dev"
        keychainGroupIdentifier = "L5262XM8UA.com.sp0n.vigilantedev"
    } else {
        keychainAppIdentifier = "L5262XM8UA.org.ctzn.safetrace"
        keychainGroupIdentifier = "L5262XM8UA.com.sp0n.vigilante"
    }
    
    let appKeychain = KeychainSwift(accessGroup: keychainAppIdentifier)
    let groupKeychain = KeychainSwift(accessGroup: keychainGroupIdentifier)

    return (appKeychain, groupKeychain)
}

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
    private(set) var user: User?

    private let environment: Environment
    private let keychain: KeychainProtocol
    private let groupKeychain: KeychainProtocol
    
    init(
        environment: Environment & UserSessionAuthenticationDelegate,
        keychains: (app: KeychainProtocol, group: KeychainProtocol) = getKeychains()
    ) {
        self.environment = environment
        self.keychain = keychains.app
        self.groupKeychain = keychains.group
        self.authenticationDelegate = environment

        setFirstTimeDefaultIfNeeded()
        attemptToLoadCachedValues()

        if !isAuthenticated {
            attemptToLoadValuesFromAppGroup(groupKeychain: groupKeychain)
        }

        if let userID = userID, let authToken = authToken {
            loadUserProfileFromAPI(userID: userID, authToken: authToken)
        }
    }

    func logout() {
        SafeTrace.stopTracing()

        updateStoredValues(token: nil, userID: nil)
        updateStoredUser(user: nil)
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

    func updateUser(_ update: (inout User) -> Void, completion: @escaping (Result<User, Error>) -> Void) {
        guard
            let userID = userID,
            let authToken = authToken,
            var userToUpdate = self.user
        else {
            assertionFailure("Attempting to update a user profile while logged out")
            completion(.failure(SessionError.notLoggedIn))
            return
        }

        update(&userToUpdate)
        updateUser(userToUpdate, userID: userID, authToken: authToken, completion: completion)
    }

    private func authenticate(withUserID userID: String, authToken: String) {
        self.updateStoredValues(token: authToken, userID: userID)
        self.loadUserProfileFromAPI(userID: userID, authToken: authToken)
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

        syncAuthTokenWebviewCookies()
    }

    func syncAuthTokenWebviewCookies(completion: (() -> Void)? = nil) {
        let authorizedCookieDict = [
            ".sp0n.io": "citizen:auth:token",
            ".citizen.com": "citizen:auth:token"
        ]
        DispatchQueue.main.async {
            let dispatchGroup = DispatchGroup()

            let dataStore = WKWebsiteDataStore.default()

            if let authToken = self.authToken {
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
                    dispatchGroup.enter()
                    dataStore.httpCookieStore.setCookie(cookie) {
                        dispatchGroup.leave()
                    }
                    HTTPCookieStorage.shared.setCookie(cookie)
                }

                dispatchGroup.notify(queue: .main) {
                    completion?()
                }
            } else {
                // Clear all web data
                // From https://gist.github.com/insidegui/4a5de215a920885e0f36294d51263a15
                dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                    records.forEach { record in
                        dispatchGroup.enter()
                        dataStore.removeData(ofTypes: record.dataTypes, for: [record]) {
                            dispatchGroup.leave()
                        }
                    }

                    dispatchGroup.notify(queue: .main) {
                        completion?()
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

        if let userProfile = getCachedUserProfile(from: self.keychain) {
            self.user = userProfile
        }
    }
    
    // Try to load shared values from Citizen app, if present
    private func attemptToLoadValuesFromAppGroup(groupKeychain: KeychainProtocol) {
        guard let authToken = getCachedAuthToken(from: groupKeychain),
            let userID = getCachedUserID(from: groupKeychain) else {
            return
        }
        
        // Persist values in this app's keychain now that we have them
        updateStoredValues(token: authToken, userID: userID)

        if let userProfile = getCachedUserProfile(from: groupKeychain) {
            self.user = userProfile
            updateStoredUser(user: userProfile)
        }
    }
    
    private func getCachedAuthToken(from keychain: KeychainProtocol) -> String? {
        return keychain.get(authTokenKeychainIdentifier)
    }
    
    private func getCachedUserID(from keychain: KeychainProtocol) -> String? {
        return keychain.get(userIDKeychainIdentifier)
    }

    private func getCachedUserProfile(from keychain: KeychainProtocol) -> User? {
        // If we can't load profile data for some reason, that's okay - we'll
        // end up loading it later via API anyway.
        guard let userData = keychain.getData(userProfileKeychainIdentifer) else {
            return nil
        }

        let user = try? JSONDecoder().decode(User.self, from: userData)
        return user
    }

    /// Since we save userID and token on keychain, it's persisted even if app is deleted
    private func setFirstTimeDefaultIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: "org.ctzn.firstInstall") else { return }

        UserDefaults.standard.set(true, forKey: "org.ctzn.firstInstall")
        logout()
    }

    private func updateStoredUser(user: User?) {
        self.user = user

        guard let user = user else {
            keychain.delete(userProfileKeychainIdentifer)
            return
        }

        do {
            let data = try JSONEncoder().encode(user)
            keychain.setData(data, forKey: userProfileKeychainIdentifer, withAccess: .accessibleAfterFirstUnlock)
        } catch { }
    }

    private func loadUserProfileFromAPI(userID: String, authToken: String, completion: ((Result<User, Error>) -> Void)? = nil) {
        environment.network.getUser(userID: userID, authToken: authToken) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure:
                    break
                case .success(let user):
                    self.updateStoredUser(user: user)
                }
                completion?(result)
            }
        }
    }

    private func updateUser(_ user: User, userID: String, authToken: String, completion: @escaping (Result<User, Error>) -> Void) {
        environment.network.updateUser(userID: userID, profile: user) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                self.updateStoredUser(user: user)
                completion(.success(user))
            }
        }
    }
}

//sourcery: AutoMockable
protocol KeychainProtocol {
    var accessGroup: String? { get set }
    @discardableResult func set(_ value: String, forKey key: String, withAccess: KeychainSwiftAccessOptions?) -> Bool
    @discardableResult func setData(_ value: Data, forKey key: String, withAccess access: KeychainSwiftAccessOptions?) -> Bool
    func get(_ key: String) -> String?
    func getData(_ key: String) -> Data?
    @discardableResult func delete(_ key: String) -> Bool
}

extension KeychainSwift: KeychainProtocol {
    func getData(_ key: String) -> Data? {
        self.getData(key, asReference: false)
    }

    public func setData(_ value: Data, forKey key: String, withAccess access: KeychainSwiftAccessOptions?) -> Bool {
        return self.set(value, forKey: key, withAccess: access)
    }
}

extension KeychainSwift {
    convenience init(accessGroup: String?) {
        self.init()
        self.accessGroup = accessGroup
    }
}
