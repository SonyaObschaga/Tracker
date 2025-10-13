import UIKit

protocol ScheduleDelegate: AnyObject {
    func didSelectSchedule(days: [Weekday])
}
