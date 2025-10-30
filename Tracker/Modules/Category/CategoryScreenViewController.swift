import UIKit

// MARK: - CategoryScreenViewController
final class CategoryScreenViewController: UIViewController {
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = []
    
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
        present(createCategoryVC, animated: true)
    }
    
    // MARK: - SetupUI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupTitleLabel()
        setupPlaceholderStackView()
        setupTableView()
        setupAddButton()
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Category Cell")
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .ypBackgroundDay
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
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
        updatePlaceholderVisibility()
    }
}

extension CategoryScreenViewController: CreateCategoryViewControllerDelegate {
    func didCreateCategory(_ category: TrackerCategory) {
        categories.append(category)
        tableView.isHidden = categories.isEmpty
        placeholderStackView.isHidden = !categories.isEmpty
        tableView.reloadData()
    }
}

extension CategoryScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Category Cell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.title
        return cell
    }
}

// extension CategoryScreenViewController: UITableViewDelegate {
//     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//         tableView.deselectRow(at: indexPath, animated: true)
//         let category = categories[indexPath.row]
//         delegate?.didSelectCategory(category)
//     }
// }
