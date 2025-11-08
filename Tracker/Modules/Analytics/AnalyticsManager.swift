import Foundation
import AppMetricaCore

final class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    private init() {}
    
    // MARK: - Configuration
    func configure() {
        guard let configuration = AppMetricaConfiguration(apiKey: "7a47e107-6bc7-473a-8fa9-4bf99392eaa3") else {
            print("Analytics: AppMetrica configuration failed")
            return
        }
        
        configuration.areLogsEnabled = true
        AppMetrica.activate(with: configuration)
        print("Analytics: AppMetrica initialized successfully")
    }
    
    // MARK: - Event Tracking
    func trackEvent(_ event: AnalyticsEvent) {
        AppMetrica.reportEvent(name: event.name, parameters: event.parameters)
        print("Analytics Event: \(event.name), Parameters: \(event.parameters)")
    }
}

// MARK: - Analytics Event Model
struct AnalyticsEvent {
    let name: String
    let parameters: [String: Any]
    
    // MARK: - Screen Events
    static func screenOpen(_ screen: Screen) -> AnalyticsEvent {
        return AnalyticsEvent(
            name: "screen_open",
            parameters: [
                "screen_name": screen.rawValue
            ]
        )
    }
    
    static func screenClose(_ screen: Screen) -> AnalyticsEvent {
        return AnalyticsEvent(
            name: "screen_close",
            parameters: [
                "screen_name": screen.rawValue
            ]
        )
    }
    
    // MARK: - Button Click Events
    static func buttonClick(_ screen: Screen, item: ButtonItem) -> AnalyticsEvent {
        return AnalyticsEvent(
            name: "button_click",
            parameters: [
                "screen_name": screen.rawValue,
                "item_name": item.rawValue
            ]
        )
    }
    
    static func userAction(_ screen: Screen, event: String, item: String? = nil) -> AnalyticsEvent {
        var parameters: [String: Any] = [
            "screen_name": screen.rawValue,
            "action_type": event
        ]
        
        if let item = item {
            parameters["item_name"] = item
        }
        
        return AnalyticsEvent(
            name: "user_action",
            parameters: parameters
        )
    }
}

// MARK: - Enums
enum Screen: String {
    case main = "Main"
}

enum ButtonItem: String {
    case addTrack = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}
