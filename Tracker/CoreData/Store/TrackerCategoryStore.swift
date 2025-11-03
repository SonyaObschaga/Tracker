import UIKit
import CoreData

protocol TrackerCategoryStoreProtocol {
    var categories: [TrackerCategory] { get }
    func fetchCategories() -> [TrackerCategory]
    func fetchCategory(with title: String) -> TrackerCategory?
    func addTracker(_ tracker: Tracker, toCategory title: String) throws
    func addCategory(_ category: TrackerCategory) throws
    func updateCategory(_ oldCategory: TrackerCategory, to newCategory: TrackerCategory) throws
    func deleteCategory(_ category: TrackerCategory) throws
}

// MARK: - TrackerCategoryStore
final class TrackerCategoryStore: NSObject {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    // MARK: - Initialization
    override init() {
        guard UIApplication.shared.delegate is AppDelegate else {
            assertionFailure("AppDelegate not found")
            self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            super.init()
            return
        }
        self.context = DataBaseStore.shared.persistentContainer.viewContext
        super.init()
        setupFetchedResultsController()
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Setup
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}

// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    
    var categories: [TrackerCategory] {
        return fetchCategories()
    }
    
    func fetchCategories() -> [TrackerCategory] {
        guard let categoryCoreDataArray = fetchedResultsController.fetchedObjects else {
            return []
        }
        
        return categoryCoreDataArray.compactMap { categoryCoreData in
            guard let title = categoryCoreData.title else { return nil }
            
            let trackers: [Tracker] = (categoryCoreData.trackers?.allObjects as? [TrackerCoreData])?
                .compactMap { trackerCoreData in
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
                } ?? []
            
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
    
    func fetchCategory(with title: String) -> TrackerCategory? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let results = try context.fetch(fetchRequest)
            guard let categoryCoreData = results.first,
                  let categoryTitle = categoryCoreData.title else { return nil }
            
            let trackers: [Tracker] = (categoryCoreData.trackers?.allObjects as? [TrackerCoreData])?
                .compactMap { convertToTracker(from: $0) } ?? []
            
            return TrackerCategory(title: categoryTitle, trackers: trackers)
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        
        for tracker in category.trackers {
            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = tracker.id.uuidString
            trackerCoreData.title = tracker.title
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.isRegular = tracker.isRegular
            trackerCoreData.color = tracker.color.toString()
            
            if let scheduleData = tracker.schedule?.toData() {
                trackerCoreData.schedule = scheduleData
            }
            
            categoryCoreData.addToTrackers(trackerCoreData)
        }
        
        try context.save()
    }
    
    func updateCategory(_ oldCategory: TrackerCategory, to newCategory: TrackerCategory) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", oldCategory.title)
        
        let results = try context.fetch(fetchRequest)
        guard let categoryCoreData = results.first else {
            throw NSError(domain: "TrackerCategoryStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Category not found"])
        }
        
        categoryCoreData.title = newCategory.title
        
        if let oldTrackers = categoryCoreData.trackers {
            categoryCoreData.removeFromTrackers(oldTrackers)
        }
        
        for tracker in newCategory.trackers {
            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = tracker.id.uuidString
            trackerCoreData.title = tracker.title
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.isRegular = tracker.isRegular
            trackerCoreData.color = tracker.color.toString()
            
            if let scheduleData = tracker.schedule?.toData() {
                trackerCoreData.schedule = scheduleData
            }
            
            categoryCoreData.addToTrackers(trackerCoreData)
        }
        
        try context.save()
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        
        let results = try context.fetch(fetchRequest)
        guard let categoryCoreData = results.first else {
            throw NSError(domain: "TrackerCategoryStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Category not found"])
        }
        
        context.delete(categoryCoreData)
        try context.save()
    }
    
    func addTracker(_ tracker: Tracker, toCategory title: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        let results = try context.fetch(fetchRequest)
        let categoryCoreData: TrackerCategoryCoreData
        
        if let existingCategory = results.first {
            categoryCoreData = existingCategory
        } else {
            categoryCoreData = TrackerCategoryCoreData(context: context)
            categoryCoreData.title = title
        }
        
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id.uuidString
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.isRegular = tracker.isRegular
        trackerCoreData.color = tracker.color.toString()
        
        if let scheduleData = tracker.schedule?.toData() {
            trackerCoreData.schedule = scheduleData
        }
        
        categoryCoreData.addToTrackers(trackerCoreData)
        try context.save()
    }
    
    // MARK: - Private Methods
    private func convertToTracker(from trackerCoreData: TrackerCoreData) -> Tracker? {
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
}
