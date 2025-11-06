import UIKit

// MARK: - SceneDelegate
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Properties
    var window: UIWindow?
    
    // MARK: - Scene Lifecycle
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = LaunchViewController()
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showAppropriateScreen()
        }
    }
    
    // MARK: - Screen Flow Logic
    private func showAppropriateScreen() {
        if !OnboardingManager.shared.isOnboardingShown {
            showOnboarding()
        } else {
            showMainScreen()
        }
    }
    
    private func showOnboarding() {
        let onboardingVC = OnboardingViewController()
        window?.rootViewController = onboardingVC
        
        UIView.transition(with: window!,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil
        )
    }
    
    func showMainScreen() {
        window?.rootViewController = TabBarController()
        
        UIView.transition(with: window!,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil
        )
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

