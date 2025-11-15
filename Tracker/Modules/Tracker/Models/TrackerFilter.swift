import Foundation

enum TrackerFilter: String, CaseIterable {
    case all = "all_trackers"
    case today = "today_trackers"
    case completed = "completed"
    case uncompleted = "uncompleted"
    
    var localizedString: String {
        return rawValue.localized
    }
    
    static var defaultFilter: TrackerFilter {
        return .all
    }
}

