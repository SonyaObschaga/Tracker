import Foundation
import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]?
    let isRegular: Bool
    
    init(id: UUID = UUID(), title: String, color: UIColor, emoji: String, schedule: [Weekday], isRegular: Bool = false) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isRegular = isRegular
    }
}

enum Weekday: Int, CaseIterable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7
    
    var localizedString: String {
        switch self {
        case .monday: return "monday".localized
        case .tuesday: return "tuesday".localized
        case .wednesday: return "wednesday".localized
        case .thursday: return "thursday".localized
        case .friday: return "friday".localized
        case .saturday: return "saturday".localized
        case .sunday: return "sunday".localized
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: return "mon".localized
        case .tuesday: return "tue".localized
        case .wednesday: return "wed".localized
        case .thursday: return "thu".localized
        case .friday: return "fri".localized
        case .saturday: return "sat".localized
        case .sunday: return "sun".localized
        }
    }
}
