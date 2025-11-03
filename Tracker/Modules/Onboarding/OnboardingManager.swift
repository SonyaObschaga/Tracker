import Foundation

final class OnboardingManager {
    static let shared = OnboardingManager()
    
    private let userDefaults = UserDefaults.standard
    private let onboardingShownKey = "onboardingShown"
    
    private init() {}
    
    var isOnboardingShown: Bool {
        get {
            return userDefaults.bool(forKey: onboardingShownKey)
        }
        set {
            userDefaults.set(newValue, forKey: onboardingShownKey)
        }
    }
    
    func markOnboardingAsShown() {
        isOnboardingShown = true
    }
}
