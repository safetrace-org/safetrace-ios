import Foundation

//sourcery: AutoMockable
protocol UserSessionAuthenticationDelegate: AnyObject {
    
    /// Called when the authentication token changes. This could be due
    /// to an authentication event, initial loading from cache, OAuth
    /// token refresh event, or any other reason. Does not necessarily
    /// indicate a change in the user's authentication state, though it
    /// may be coincident with such a change.
    func authenticationStatusDidChange(forSession: UserSessionProtocol)
    
    /// Called after any authentication event, one of: log in, sign up,
    /// or log out.
    func authenticationTokenDidChange(forSession: UserSessionProtocol)
}

public protocol SafeTraceSession {
    var isAuthenticated: Bool { get }
    var userID: String? { get }
    var authToken: String? { get }
    var user: User? { get }
    var isCitizenAuthenticated: Bool { get }

    func requestAuthenticationCode(for phone: String, completion: @escaping (Result<Void, Error>) -> Void)
    func authenticateWithCode(_: String, phone: String, completion: @escaping (Result<LoginResponseContext, Error>) -> Void)
    func authenticateWithEmailCode(_ code: String, phone: String, completion: @escaping (Result<Void, Error>) -> Void)
    func resendEmailAuthCode(phone: String, deviceID: String?, completion: @escaping (Result<Void, Error>) -> Void)
    func updateUser(_ update: (inout User) -> Void, completion: @escaping (Result<User, Error>) -> Void)
    func setAPNSToken(_ token: Data)
    func syncAuthTokenWebviewCookies(completion: (() -> Void)?)
    func logout()
}

//sourcery: AutoMockable
protocol UserSessionProtocol: AnyObject, SafeTraceSession {
    var authenticationDelegate: UserSessionAuthenticationDelegate? { get set }
    var userIDDidChange: ((_ userID: String?) -> Void)? { get set }

    var isAuthenticated: Bool { get }
    var isCitizenAuthenticated: Bool { get }
    var userID: String? { get }
    var authToken: String? { get }

    func authenticateWithCode(_: String, phone: String, completion: @escaping (Result<LoginResponseContext, Error>) -> Void)
}
