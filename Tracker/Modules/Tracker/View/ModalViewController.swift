import UIKit

struct SettingsOption {
    let title: String
    let subtitle: String?
    let type: SettingsOptionType
}

enum SettingsOptionType {
    case category
    case schedule
}

var settingsOptions: [SettingsOption] = [
    SettingsOption(title: "Категория", subtitle: nil, type: .category),
    SettingsOption(title: "Расписание", subtitle: nil, type: .schedule)
]

// MARK: - CreateHabitController
final class CreateHabitController: UIViewController, UITextFieldDelegate {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let textFieldOfHabitName = UITextField()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        setupTitleLabel()
        setupTextFieldOfHabitName()
        setupTableViewOfHabits()
        self.textFieldOfHabitName.delegate = self
    }
    
    func setupTitleLabel() {
        titleLabel.text = "Новая привычка"
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
    
    func setupTextFieldOfHabitName() {
        textFieldOfHabitName.placeholder = "Введите название трекера"
        textFieldOfHabitName.textColor = .ypGray
        textFieldOfHabitName.backgroundColor = .ypBackgroundDay
        textFieldOfHabitName.layer.masksToBounds = true
        textFieldOfHabitName.layer.cornerRadius = 16
        textFieldOfHabitName.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textFieldOfHabitName.clearButtonMode = .whileEditing


        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textFieldOfHabitName.frame.height))
        textFieldOfHabitName.leftView = paddingView
        textFieldOfHabitName.leftViewMode = .always
        
        textFieldOfHabitName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textFieldOfHabitName)
        
        NSLayoutConstraint.activate([
            textFieldOfHabitName.heightAnchor.constraint(equalToConstant: 75),
            textFieldOfHabitName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldOfHabitName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textFieldOfHabitName.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38)
        ])
    }
    
    func setupTableViewOfHabits() {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
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
            tableView.topAnchor.constraint(equalTo: textFieldOfHabitName.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func openCategoryScreen() {
        let categoryScreenVC = CategoryScreenViewController()
        present(categoryScreenVC, animated: true, completion: nil)
    }
    
    private func openScheduleScreen() {
        let scheduleScreenVC = ScheduleScreenViewController()
        present(scheduleScreenVC, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension CreateHabitController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let option = settingsOptions[indexPath.row]
        
        cell.textLabel?.text = option.title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.backgroundColor = .ypBackgroundDay
        cell.accessoryType = .disclosureIndicator
        
        if indexPath.row == settingsOptions.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
    
    
}

extension CreateHabitController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let option = settingsOptions[indexPath.row]
        
        switch option.type {
        case .category:
            openCategoryScreen()
        case .schedule:
            openScheduleScreen()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}



#Preview {
    CreateHabitController()
}
