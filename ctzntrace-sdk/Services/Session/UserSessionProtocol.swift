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

//sourcery: AutoMockable
protocol UserSessionProtocol: AnyObject {
    var authenticationDelegate: UserSessionAuthenticationDelegate? { get set }
    
    var isAuthenticated: Bool { get }
    var userID: String? { get }
    var authToken: String? { get }

    func logout()

    func authenticateWithCode(_: String, phone: String, completion: @escaping (Result<Void, Error>) -> Void)
}
