import UIKit
import AppMetricaCore
import AppMetricaCrashes

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AnalyticsManager.shared.configure()
        setupCrashTracking()
        return true
    }
    
    // MARK: - AppMetrica Configuration
    private func setupCrashTracking() {
        let crashesConfiguration = AppMetricaCrashesConfiguration()
        crashesConfiguration.autoCrashTracking = true
        
        AppMetricaCrashes.crashes().setConfiguration(crashesConfiguration)
    }
    
    // MARK: - UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

