import Foundation

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var nextDay: Date {
        guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            assertionFailure("Failed to calculate next day")
            return startOfDay
        }
        return nextDate
    }
}
