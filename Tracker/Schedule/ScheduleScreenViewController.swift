import UIKit

struct ScheduleOption {
    let weekday: Weekday
    var isSelected: Bool
}

// MARK: - ScheduleScreenViewController
final class ScheduleScreenViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let readyButton = UIButton()
    
    // MARK: - Data
    private var scheduleOptions: [ScheduleOption] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        setupTitleLabel()
        setupData()
        setupTableView()
        setupReadyButton()
    }
    
    // MARK: - Actions
    @objc private func switchValueChanged(_ sender: UISwitch) {
        let index = sender.tag
        scheduleOptions[index].isSelected = sender.isOn
    }
    
    // MARK: - Private Methods
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
            ScheduleOption(weekday: weekday, isSelected: false)
        }
    }
    
    private func setupReadyButton() {
        readyButton.backgroundColor = .ypBlackDay
        readyButton.layer.cornerRadius = 16
        readyButton.layer.masksToBounds = true
        readyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        readyButton.setTitle("Готово", for: .normal)
        readyButton.setTitleColor(.ypWhiteDay, for: .normal)
        
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(readyButton)
        
        NSLayoutConstraint.activate([
            readyButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 47),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
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
