import CoreData
import UIKit

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init() {
        guard UIApplication.shared.delegate is AppDelegate else {
            assertionFailure("AppDelegate not found")
            self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

            return
        }
        self.context = DataBaseStore.shared.persistentContainer.viewContext
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addRecord(trackerId: UUID, date: Date) throws {
        let record = TrackerRecordCoreData(context: context)
        record.trackerId = trackerId.uuidString
        record.date = date
        
        try context.save()
    }
    
    func removeRecord(trackerId: UUID, date: Date) throws {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "trackerId == %@ AND date >= %@ AND date < %@",
            trackerId.uuidString,
            date.startOfDay as CVarArg,
            date.nextDay as CVarArg
        )
        
        let results = try context.fetch(fetchRequest)
        for record in results {
            context.delete(record)
        }
        
        try context.save()
    }
    
    func fetchRecords() throws -> [TrackerRecord] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let records = try context.fetch(fetchRequest)
        
        return records.compactMap { record in
            guard let trackerIdString = record.trackerId,
                  let trackerId = UUID(uuidString: trackerIdString),
                  let date = record.date else {
                return nil
            }
            return TrackerRecord(trackerId: trackerId, date: date)
        }
    }
    
    func isTrackerCompletedToday(id: UUID, date: Date) throws -> Bool {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "trackerId == %@ AND date >= %@ AND date < %@",
            id.uuidString,
            date.startOfDay as CVarArg,
            date.nextDay as CVarArg
        )
        
        let count = try context.count(for: fetchRequest)
        return count > 0
    }
    
    func completedDaysCount(for trackerId: UUID) throws -> Int {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", trackerId.uuidString)
        
        let count = try context.count(for: fetchRequest)
        return count
    }
    
    func deleteRecords(for trackerId: UUID) throws {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", trackerId.uuidString)
        
        let results = try context.fetch(fetchRequest)
        for record in results {
            context.delete(record)
        }
        
        try context.save()
    }
}
