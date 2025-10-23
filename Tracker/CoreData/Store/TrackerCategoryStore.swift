import UIKit
import CoreData

final class TrackerCategoryStore {
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
    
    func fetchCategories() -> [TrackerCategory] {
        let allTrackers = fetchAllTrackers()
        
        if allTrackers.isEmpty {
            return []
        } else {
            return [TrackerCategory(title: "Важное", trackers: allTrackers)]
        }
    }
    
    private func fetchAllTrackers() -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        do {
            let trackerCoreDataArray = try context.fetch(fetchRequest)
            return trackerCoreDataArray.compactMap { trackerCoreData in
                guard let idString = trackerCoreData.id,
                      let id = UUID(uuidString: idString),
                      let title = trackerCoreData.title,
                      let emoji = trackerCoreData.emoji,
                      let colorString = trackerCoreData.color,
                      let color = UIColor.fromString(colorString) else {
                    return nil
                }
                
                let schedule: [Weekday]?
                if let scheduleData = trackerCoreData.schedule {
                    schedule = [Weekday].fromData(scheduleData)
                } else {
                    schedule = nil
                }
                
                return Tracker(
                    id: id,
                    title: title,
                    color: color,
                    emoji: emoji,
                    schedule: schedule ?? [],
                    isRegular: trackerCoreData.isRegular
                )
            }
        } catch {
            print("Ошибка загрузки трекеров: \(error)")
            return []
        }
    }
    
    func addTracker(_ tracker: Tracker, toCategory title: String) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id.uuidString
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.isRegular = tracker.isRegular
        trackerCoreData.color = tracker.color.toString()
        
        if let scheduleData = tracker.schedule?.toData() {
            trackerCoreData.schedule = scheduleData
        }
        
        trackerCoreData.categoryTitle = title
        try context.save()
    }
    
    func fetchCategory(with title: String) -> TrackerCategory? {
        let allTrackers = fetchAllTrackers()
        
        if allTrackers.isEmpty {
            return nil
        } else {
            return TrackerCategory(title: "Важное", trackers: allTrackers)
        }
    }
}
