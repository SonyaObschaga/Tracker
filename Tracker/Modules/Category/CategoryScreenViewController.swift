import UIKit

// MARK: - CategoryScreenViewController
final class CategoryScreenViewController: UIViewController {
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = []
    private var selectedCategory: TrackerCategory?
    private var previouslySelectedIndexPath: IndexPath?
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let placeholderStackView = UIStackView()
    private let addButton = UIButton()
    private let tableView = UITableView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updatePlaceholderVisibility()
    }
    
    // MARK: - Actions
    @objc private func didTapAddButton() {
        let createCategoryVC = CreateCategoryViewController()
        createCategoryVC.delegate = self
        present(createCategoryVC, animated: true)
    }
    
    // MARK: - SetupUI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupTitleLabel()
        setupPlaceholderStackView()
        setupAddButton()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Category Cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 0)
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Категория"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .ypBlackDay
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupPlaceholderStackView() {
        placeholderStackView.translatesAutoresizingMaskIntoConstraints = false
        placeholderStackView.axis = .vertical
        placeholderStackView.alignment = .center
        placeholderStackView.spacing = 8
        
        let placeholderImage = UIImageView(image: UIImage(named: "dizzy"))
        placeholderImage.contentMode = .scaleAspectFit
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
        ])
        
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Привычки и события можно\n объединить по смыслу"
        placeholderLabel.textAlignment = .center
        placeholderLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textColor = .label
        placeholderLabel.numberOfLines = 2
        
        placeholderStackView.addArrangedSubview(placeholderImage)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        
        view.addSubview(placeholderStackView)
        NSLayoutConstraint.activate([
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setupAddButton() {
        addButton.backgroundColor = .ypBlackDay
        addButton.layer.masksToBounds = true
        addButton.layer.cornerRadius = 16
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        addButton.setTitle("Добавить категорию", for: .normal)
        addButton.setTitleColor(.ypWhiteDay, for: .normal)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Private Methods
    private func updatePlaceholderVisibility() {
        let isEmpty = categories.isEmpty
        placeholderStackView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        tableView.reloadData()
    }
    
    private func updateTableViewHeight() {
        let rowHeight: CGFloat = 75
        let numberOfRows = categories.count
        let totalHeight = CGFloat(numberOfRows) * rowHeight
        
        if let heightConstraint = tableView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = totalHeight
        }
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateAllCellSeparators() {
        for visibleCell in tableView.visibleCells {
            if let indexPath = tableView.indexPath(for: visibleCell) {
                if indexPath.row == categories.count - 1 {
                    visibleCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                } else {
                    visibleCell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
                }
            }
        }
    }
    
    // MARK: - Context Menu
    private func editCategory(at indexPath: IndexPath) {
        let categoryToEdit = categories[indexPath.row]
        let editVC = EditCategoryViewController()
        editVC.delegate = self
        editVC.editingCategory = categoryToEdit
        present(editVC, animated: true)
    }
    
    private func deleteCategory(at indexPath: IndexPath) {
        let categoryToDelete = categories[indexPath.row]
        
        let alert = UIAlertController(
            title: "Эта категория точно не нужна?",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "Удалить?", style: .destructive) { [weak self] _ in
            self?.performDeleteCategory(at: indexPath, categoryToDelete: categoryToDelete)
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func createContextMenu(for indexPath: IndexPath) -> UIMenu {
        let editAction = UIAction(
            title: "Редактировать",
            image: nil
        ) { [weak self] _ in
            self?.editCategory(at: indexPath)
        }
        
        let deleteAction = UIAction(
            title: "Удалить",
            image: nil,
            attributes: .destructive
        ) { [weak self] _ in
            self?.deleteCategory(at: indexPath)
        }
        
        return UIMenu(title: "", children: [editAction, deleteAction])
    }
    
    private func performDeleteCategory(at indexPath: IndexPath, categoryToDelete: TrackerCategory) {
        categories.remove(at: indexPath.row)
        let wasSelectedCategory = selectedCategory?.title == categoryToDelete.title
        
        if wasSelectedCategory {
            selectedCategory = nil
            previouslySelectedIndexPath = nil
        }
        
        if categories.isEmpty {
            updateUIAfterCategoryChange()
        } else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updateTableViewHeight()
            updateAllCellSeparators()
        }
    }
    private func updateUIAfterCategoryChange() {
        tableView.reloadData()
        updatePlaceholderVisibility()
        updateTableViewHeight()
        updateAllCellSeparators()
    }
}

// MARK: - CreateCategoryViewControllerDelegate
extension CategoryScreenViewController: CreateCategoryViewControllerDelegate {
    func didCreateCategory(_ category: TrackerCategory) {
        categories.append(category)
        tableView.isHidden = categories.isEmpty
        placeholderStackView.isHidden = !categories.isEmpty
        
        updateUIAfterCategoryChange()
    }
    
    func didUpdateCategory(from oldCategory: TrackerCategory, to newCategory: TrackerCategory) {
        if let index = categories.firstIndex( where: {$0.title == oldCategory.title }) {
            categories[index] = newCategory
            
            if selectedCategory?.title == oldCategory.title {
                selectedCategory = newCategory
            }
        }
        updateUIAfterCategoryChange()
    }
}

// MARK: - UITableViewDataSource
extension CategoryScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Category Cell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.title
        cell.backgroundColor = .ypBackgroundDay
        
        let isSelected = selectedCategory?.title == category.title
        cell.accessoryType = isSelected ? .checkmark : .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var indexPathsToReload = [indexPath]
        
        if let previousIndexPath = previouslySelectedIndexPath {
            indexPathsToReload.append(previousIndexPath)
        }
        
        selectedCategory = categories[indexPath.row]
        previouslySelectedIndexPath = indexPath
        
        tableView.reloadRows(at: indexPathsToReload, with: .none)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let identifier = "\(indexPath.row)" as NSString
        
        return UIContextMenuConfiguration(
            identifier: identifier,
            previewProvider: nil
        ) { [weak self] _ in
            return self?.createContextMenu(for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard
            let identifier = configuration.identifier as? String,
            let index = Int(identifier),
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
        else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        return UITargetedPreview(view: cell, parameters: parameters)
    }
}
