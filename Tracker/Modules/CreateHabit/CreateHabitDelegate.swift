import UIKit

protocol CreateHabitDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, in category: TrackerCategory)
    func didUpdateTracker(_ tracker: Tracker, in category: TrackerCategory)
}
