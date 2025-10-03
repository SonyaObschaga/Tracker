import UIKit

struct ScheduleOption {
    let weekday: Weekday
    var isSelected: Bool
}

// MARK: - ScheduleScreenViewController
final class ScheduleScreenViewController: UIViewController {
    
    // MARK: - Properties
    private var scheduleOptions: [ScheduleOption] = []
    weak var delegate: ScheduleDelegate?
    var selectedDays: [Weekday] = []
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let doneButton = UIButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    // MARK: - Actions
    @objc private func switchValueChanged(_ sender: UISwitch) {
        let index = sender.tag
        scheduleOptions[index].isSelected = sender.isOn
    }
    
    @objc private func doneButtonTapped() {
        selectedDays = scheduleOptions
            .filter { $0.isSelected }
            .map { $0.weekday }
        
        delegate?.didSelectSchedule(days: selectedDays)
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
        setupTitleLabel()
        setupTableView()
        setupDoneButton()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Расписание"
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Schedule Cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .ypBackgroundDay
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 35),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525)
        ])
    }
    
    private func setupData() {
        scheduleOptions = Weekday.allCases.map { weekday in
            let isSelected = selectedDays.contains(weekday)
            return ScheduleOption(weekday: weekday, isSelected: isSelected)
        }
    }
    
    private func setupDoneButton() {
        doneButton.backgroundColor = .ypBlackDay
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.ypWhiteDay, for: .normal)
        
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 47),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - UITableViewDataSource
extension ScheduleScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Schedule Cell", for: indexPath)
        let scheduleOption = scheduleOptions[indexPath.row]
        
        cell.textLabel?.text = scheduleOption.weekday.localizedString
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.backgroundColor = .ypBackgroundDay
        
        let switchView = UISwitch()
        switchView.onTintColor = .systemBlue
        switchView.isOn = scheduleOption.isSelected
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        
        cell.accessoryView = switchView
        cell.selectionStyle = .none
        
        if indexPath.row == scheduleOptions.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScheduleScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

#Preview {
    ScheduleScreenViewController()
}
