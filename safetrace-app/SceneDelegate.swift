import SafeTrace
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        
        self.window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        
        if SafeTrace.session.isAuthenticated {
            navigationController.viewControllers = [HomeViewController()]
        } else {
            navigationController.viewControllers = [PhoneAuthenticationViewController()]
        }
        
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
}
