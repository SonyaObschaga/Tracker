import UIKit

protocol CreateHabitDelegate: AnyObject {
    func didCreateNewTracker(_ tracker: Tracker, category: String)
}
