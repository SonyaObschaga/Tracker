import Foundation

extension Array where Element == Weekday {
    func toData() -> Data? {
        let rawValues = self.map { $0.rawValue }
        return try? JSONEncoder().encode(rawValues)
    }
    
    static func fromData(_ data: Data) -> [Weekday]? {
        guard let rawValues = try? JSONDecoder().decode([Int].self, from: data) else { return nil }
        return rawValues.compactMap { Weekday(rawValue: $0) }
    }
}
