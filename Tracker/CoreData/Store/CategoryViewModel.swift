import UIKit
import CoreData

// MARK: - Category ViewModel
final class CategoryViewModel: NSObject {
    
    // MARK: - Binding Closures
    var categoriesDidChange: (() -> Void)?
    var selectedCategoryDidChange: ((TrackerCategory?) -> Void)?
    var placeholderVisibilityDidChange: ((Bool) -> Void)?
    
    // MARK: - Properties
    private let categoryStore: TrackerCategoryStoreProtocol
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            categoriesDidChange?()
            placeholderVisibilityDidChange?(categories.isEmpty)
        }
    }
    
    private(set) var selectedCategory: TrackerCategory? {
        didSet {
            selectedCategoryDidChange?(selectedCategory)
        }
    }
    
    // MARK: - Initialization
    init(categoryStore: TrackerCategoryStoreProtocol) {
        self.categoryStore = categoryStore
        super.init()
        loadCategories()
    }
    
    // MARK: - Public Methods
    func loadCategories() {
        self.categories = categoryStore.fetchCategories()
    }
    
    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        selectedCategory = categories[index]
    }
    
    func selectCategory(_ category: TrackerCategory?) {
        selectedCategory = category
    }
    
    func addCategory(_ category: TrackerCategory) {
        do {
            try categoryStore.addCategory(category)
        } catch {
            handleError(error)
        }
    }
    
    func updateCategory(from oldCategory: TrackerCategory, to newCategory: TrackerCategory) {
        do {
            try categoryStore.updateCategory(oldCategory, to: newCategory)
            if selectedCategory?.title == oldCategory.title {
                selectedCategory = newCategory
            }
        } catch {
            handleError(error)
        }
    }
    
    func deleteCategory(at index: Int) {
        guard index < categories.count else { return }
        let categoryToDelete = categories[index]
        
        do {
            try categoryStore.deleteCategory(categoryToDelete)
            if selectedCategory?.title == categoryToDelete.title {
                selectedCategory = nil
            }
        } catch {
            handleError(error)
        }
    }
    
    func category(at index: Int) -> TrackerCategory? {
        guard index < categories.count else { return nil }
        return categories[index]
    }
    
    func isCategorySelected(_ category: TrackerCategory) -> Bool {
        return selectedCategory?.title == category.title
    }
    
    var numberOfCategories: Int {
        return categories.count
    }
    
    var shouldShowPlaceholder: Bool {
        return categories.isEmpty
    }
    
    // MARK: - Private Methods
    private func handleError(_ error: Error) {
        let alert = UIAlertController(title: "Ошибка",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
    }
}
