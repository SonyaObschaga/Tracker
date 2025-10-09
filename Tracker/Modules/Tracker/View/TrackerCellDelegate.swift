import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completetracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}
