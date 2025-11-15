import UIKit

// MARK: - FilterDelegate
protocol FilterDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

// MARK: - FilterViewController
final class FilterViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: FilterDelegate?
    var selectedFilter: TrackerFilter = .all
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupTitleLabel()
        setupTableView()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "filters".localized
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .ypBlackDay
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30)
        ])
    }
    
    private func setupTableView() {
        tableView.register(FilterTableViewCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .ypBackgroundDay
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let rowHeight: CGFloat = 75
        let totalHeight = CGFloat(TrackerFilter.allCases.count) * rowHeight
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: totalHeight)
        ])
    }
}

// MARK: - UITableViewDataSource
extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackerFilter.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as? FilterTableViewCell else {
            return UITableViewCell()
        }
        
        let filter = TrackerFilter.allCases[indexPath.row]
        let isSelected = filter == selectedFilter
        let filtersWithoutCheckmark: [TrackerFilter] = [.all, .today]
        let shouldShowCheckmark = !filtersWithoutCheckmark.contains(filter)
        
        cell.configure(with: filter, isSelected: isSelected, shouldShowCheckmark: shouldShowCheckmark)
        cell.selectionStyle = .none
        
        if indexPath.row == TrackerFilter.allCases.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedFilter = TrackerFilter.allCases[indexPath.row]
        delegate?.didSelectFilter(selectedFilter)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

