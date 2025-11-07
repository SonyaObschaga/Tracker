import UIKit

// MARK: - CategoryScreenViewController
final class CategoryScreenViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CategoryViewModel
    private var previouslySelectedIndexPath: IndexPath?
    weak var delegate: CategorySelectionDelegate?
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let placeholderStackView = UIStackView()
    private let addButton = UIButton()
    private let tableView = UITableView()
    
    // MARK: - Initialization
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        updateUI()
    }
    
    // MARK: - Actions
    @objc private func didTapAddButton() {
        let createCategoryVC = CreateCategoryViewController()
        createCategoryVC.delegate = self
        present(createCategoryVC, animated: true)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupTitleLabel()
        setupPlaceholderStackView()
        setupAddButton()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "CategoryCell")
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
        titleLabel.text = "category".localized
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
        placeholderLabel.text = "habits_events_grouped".localized
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
        
        addButton.setTitle("add_category".localized, for: .normal)
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
    
    // MARK: - Binding
    private func setupBindings() {
        viewModel.categoriesDidChange = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.placeholderVisibilityDidChange = { [weak self] isEmpty in
            DispatchQueue.main.async {
                self?.updatePlaceholderVisibility()
            }
        }
        
        viewModel.selectedCategoryDidChange = { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.onError = { [weak self] error in
            self?.showErrorAlert(error)
        }
    }


    
    // MARK: - Private Methods
    private func updateUI() {
        tableView.reloadData()
        updatePlaceholderVisibility()
        updateTableViewHeight()
        updateAllCellSeparators()
    }
    
    private func updatePlaceholderVisibility() {
        let isEmpty = viewModel.shouldShowPlaceholder
        placeholderStackView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func updateTableViewHeight() {
        let rowHeight: CGFloat = 75
        let totalHeight = CGFloat(viewModel.numberOfCategories) * rowHeight
        
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
                if indexPath.row == viewModel.numberOfCategories - 1 {
                    visibleCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                } else {
                    visibleCell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
                }
            }
        }
    }
    
    // MARK: - Context Menu
    private func editCategory(at indexPath: IndexPath) {
        guard let categoryToEdit = viewModel.category(at: indexPath.row) else { return }
        let editVC = EditCategoryViewController()
        editVC.delegate = self
        editVC.editingCategory = categoryToEdit
        present(editVC, animated: true)
    }
    
    private func deleteCategory(at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "confirm_category_deletion?".localized,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "delete_question".localized, style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(at: indexPath.row)
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func createContextMenu(for indexPath: IndexPath) -> UIMenu {
        let editAction = UIAction(
            title: "edit".localized,
            image: nil
        ) { [weak self] _ in
            self?.editCategory(at: indexPath)
        }
        
        let deleteAction = UIAction(
            title: "delete".localized,
            image: nil,
            attributes: .destructive
        ) { [weak self] _ in
            self?.deleteCategory(at: indexPath)
        }
        
        return UIMenu(title: "", children: [editAction, deleteAction])
    }
    
    private func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "error".localized,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "ok".localized, style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}

// MARK: - CreateCategoryViewControllerDelegate
extension CategoryScreenViewController: CreateCategoryViewControllerDelegate {
    func didCreateCategory(_ category: TrackerCategory) {
        viewModel.addCategory(category)
    }
    
    func didUpdateCategory(from oldCategory: TrackerCategory, to newCategory: TrackerCategory) {
        viewModel.updateCategory(from: oldCategory, to: newCategory)
    }
}

// MARK: - UITableViewDataSource
extension CategoryScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CategoryCell",
            for: indexPath
        ) as? CategoryTableViewCell,
              let category = viewModel.category(at: indexPath.row) else {
            return UITableViewCell()
        }
        
        let isSelected = viewModel.isCategorySelected(category)
        cell.configure(with: category, isSelected: isSelected)
        
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
        
        viewModel.selectCategory(at: indexPath.row)
        previouslySelectedIndexPath = indexPath
        
        delegate?.didSelectCategory(viewModel.selectedCategory)
        
        tableView.reloadRows(at: indexPathsToReload, with: .none)
        dismiss(animated: true)
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
