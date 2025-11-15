import Foundation

// MARK: - Localization
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(_ args: CVarArg...) -> String {
        return String(format: localized, arguments: args)
    }
}

// MARK: - Pluralization
enum Localization {
    static func daysCount(_ count: Int) -> String {
        let format = NSLocalizedString("days_count", comment: "")
        return String(format: format, count)
    }
}
