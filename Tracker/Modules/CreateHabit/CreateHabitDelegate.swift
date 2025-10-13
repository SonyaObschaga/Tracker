import UIKit

protocol CreateHabitDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, in category: TrackerCategory)
}
