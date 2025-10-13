import Foundation

struct SettingsOption {
    let title: String
    var subtitle: String?
    let type: SettingsOptionType
}

enum SettingsOptionType {
    case category
    case schedule
}
