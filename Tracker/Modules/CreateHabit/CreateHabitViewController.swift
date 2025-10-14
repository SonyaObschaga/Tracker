import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory?)
}

// MARK: - CreateHabitController
final class CreateHabitViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let textFieldOfHabitName = UITextField()
    private let cancelButton = UIButton()
    private let createButton = UIButton()
    private let tableView = UITableView()
    private var tableViewTopConstraint: NSLayoutConstraint!
    private let emojies = [
        "❤️", "🍏", "🧊", "💭", "💕", "😍", "🔎", "😎", "💍",
        "🚗", "⛔️", "🇷🇺", "🐸", "🐻", "🐶", "🐱", "🐭", "🐹"
    ]
    private let colors: [(String, UIColor)] = [
        ("Красный", UIColor(red: 0.961, green: 0.420, blue: 0.424, alpha: 1.0)),
        ("Оранжевый", UIColor(red: 0.992, green: 0.584, blue: 0.318, alpha: 1.0)),
        ("Желтый", UIColor(red: 0.996, green: 0.769, blue: 0.318, alpha: 1.0)),
        ("Зеленый", UIColor(red: 0.459, green: 0.820, blue: 0.408, alpha: 1.0)),
        ("Голубой", UIColor(red: 0.318, green: 0.737, blue: 0.996, alpha: 1.0)),
        ("Синий", UIColor(red: 0.216, green: 0.447, blue: 0.906, alpha: 1.0)),
        ("Фиолетовый", UIColor(red: 0.584, green: 0.318, blue: 0.996, alpha: 1.0)),
        ("Розовый", UIColor(red: 0.996, green: 0.318, blue: 0.737, alpha: 1.0)),
        ("Коричневый", UIColor(red: 0.584, green: 0.318, blue: 0.216, alpha: 1.0)),
        ("Серый", UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1.0)),
        ("Черный", UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1.0)),
        ("Белый", UIColor(red: 0.996, green: 0.996, blue: 0.996, alpha: 1.0)),
        ("Темно-зеленый", UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)),
        ("Темно-синий", UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)),
        ("Золотой", UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)),
        ("Серебряный", UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)),
        ("Бирюзовый", UIColor(red: 0.0, green: 0.8, blue: 0.8, alpha: 1.0)),
        ("Лавандовый", UIColor(red: 0.9, green: 0.9, blue: 0.98, alpha: 1.0))
    ]
    
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.isHidden = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    // MARK: - Private Properties
    private var selectedSchedule: [Weekday] = []
    var categories: [TrackerCategory] = []
    private var selectedCategory: TrackerCategory?
    weak var delegate: CreateHabitDelegate?
    private var settingsOptions: [SettingsOption] = [
        SettingsOption(title: "Категория", subtitle: "Важное", type: .category),
        SettingsOption(title: "Расписание", subtitle: nil, type: .schedule)
    ]
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.textFieldOfHabitName.delegate = self
        updateCreateButtonState()
    }
    
    // MARK: - Actions
    @objc private func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapCreateButton() {
        guard let trackerName = textFieldOfHabitName.text, !trackerName.isEmpty, !selectedSchedule.isEmpty,
              let selectedEmoji = selectedEmoji, let selectedColor = selectedColor else { return }
        
        let categoryToUse = selectedCategory ?? getDefaultCategory()
        
        let newTracker = Tracker(
            id: UUID(),
            title: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedSchedule,
            isRegular: true)
        
        delegate?.didCreateTracker(newTracker, in: categoryToUse)
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    // MARK: - SetupUI
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
        setupTitleLabel()
        setupTextFieldOfHabitName()
        setupWarningLabel()
        setupTableViewOfHabits()
        setupButtons()
        setupCollectionView()
    }
    
    private func setupButtons() {
        setupCreateButton()
        setupCancelButton()
        
        NSLayoutConstraint.activate([
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            createButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
    }
    
    private func openCategoryScreen() {
        let categoryScreenVC = CategoryScreenViewController()
        present(categoryScreenVC, animated: true, completion: nil)
    }
    
    private func openScheduleScreen() {
        let scheduleScreenVC = ScheduleScreenViewController()
        scheduleScreenVC.delegate = self
        scheduleScreenVC.selectedDays = selectedSchedule
        present(scheduleScreenVC, animated: true, completion: nil)
    }
    
    private func updateScheduleSubtitle() {
        let scheduleText: String
        
        if selectedSchedule.isEmpty {
            scheduleText = ""
        } else if selectedSchedule.count == Weekday.allCases.count {
            scheduleText = "Каждый день"
        } else {
            let sortedDays = selectedSchedule.sorted { $0.rawValue < $1.rawValue }
            scheduleText = sortedDays.map { $0.shortName }.joined(separator: ", ")
        }
        
        settingsOptions[1] = SettingsOption(
            title: "Расписание",
            subtitle: scheduleText.isEmpty ? nil : scheduleText,
            type: .schedule
        )
        
        print("Обновляем subtitle: '\(scheduleText)'")
        let scheduleIndexPath = IndexPath(row: 1, section: 0)
        tableView.reloadRows(at: [scheduleIndexPath], with: .automatic)
    }
    
    private func setupTitleLabel() {
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
    
    private func setupTextFieldOfHabitName() {
        textFieldOfHabitName.placeholder = "Введите название трекера"
        textFieldOfHabitName.textColor = .ypBlackDay
        textFieldOfHabitName.backgroundColor = .ypBackgroundDay
        textFieldOfHabitName.layer.masksToBounds = true
        textFieldOfHabitName.layer.cornerRadius = 16
        textFieldOfHabitName.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textFieldOfHabitName.clearButtonMode = .whileEditing
        textFieldOfHabitName.returnKeyType = .done
        textFieldOfHabitName.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
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
    
    private func setupTableViewOfHabits() {
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
        
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: textFieldOfHabitName.bottomAnchor, constant: 24)
        
        NSLayoutConstraint.activate([
            tableViewTopConstraint,
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func setupCancelButton() {
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34)
        ])
    }
    
    private func setupCreateButton() {
        createButton.backgroundColor = .ypGray
        createButton.layer.masksToBounds = true
        createButton.layer.cornerRadius = 16
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.isEnabled = false
        
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.ypWhiteDay, for: .normal)
        
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)
        
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34)
        ])
    }
    
    private func setupWarningLabel() {
        view.addSubview(warningLabel)
        
        NSLayoutConstraint.activate([
            warningLabel.topAnchor.constraint(equalTo: textFieldOfHabitName.bottomAnchor, constant: 8),
            warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmojiColorCell.self, forCellWithReuseIdentifier: "EmojiColorCell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }
    
    
    
    // MARK: - Private Methods
    private func getDefaultCategory() -> TrackerCategory {
        if let generalCategory = categories.first(where: { $0.title == "Общее" }) {
            return generalCategory
        } else {
            return TrackerCategory(title: "Общее", trackers: [])
        }
    }
    
    private func updateCreateButtonState() {
        let isFormValid = !(textFieldOfHabitName.text?.isEmpty ?? true) && !selectedSchedule.isEmpty
        
        createButton.isEnabled = isFormValid
        createButton.backgroundColor = isFormValid ? .ypBlackDay : .ypGray
    }
    
    private func showWarningLabel() {
        guard warningLabel.isHidden else { return }
        
        warningLabel.isHidden = false
        warningLabel.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.tableViewTopConstraint.isActive = false
            self.tableViewTopConstraint = self.tableView.topAnchor.constraint(equalTo: self.warningLabel.bottomAnchor, constant: 32)
            self.tableViewTopConstraint.isActive = true
            
            self.warningLabel.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideWarningLabel() {
        guard !warningLabel.isHidden else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.tableViewTopConstraint.isActive = false
            self.tableViewTopConstraint = self.tableView.topAnchor.constraint(equalTo: self.textFieldOfHabitName.bottomAnchor, constant: 24)
            self.tableViewTopConstraint.isActive = true
            
            self.warningLabel.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.warningLabel.isHidden = true
        }
    }
}

// MARK: - UITableViewDataSource
extension CreateHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let option = settingsOptions[indexPath.row]
        
        cell.textLabel?.text = option.title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.backgroundColor = .ypBackgroundDay
        cell.accessoryType = .disclosureIndicator
        
        if let subtitle = option.subtitle {
            cell.detailTextLabel?.text = subtitle
            cell.detailTextLabel?.textColor = .ypGray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        } else {
            cell.detailTextLabel?.text = nil
        }
        
        if indexPath.row == settingsOptions.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CreateHabitViewController: UITableViewDelegate {
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

// MARK: - UITextFieldDelegate
extension CreateHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let rangeRange = Range(range, in: currentText) else { return false }
        let newText = currentText.replacingCharacters(in: rangeRange, with: string)
        let maxLength = 38
        
        if newText.count >= maxLength - 5 {
            showWarningLabel()
        } else {
            hideWarningLabel()
        }
        
        DispatchQueue.main.async {
            self.updateCreateButtonState()
        }
        
        return newText.count <= maxLength
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        hideWarningLabel()
        DispatchQueue.main.async {
            self.updateCreateButtonState()
        }
        
        return true
    }
}

// MARK: - ScheduleDelegate
extension CreateHabitViewController: ScheduleDelegate {
    func didSelectSchedule(days: [Weekday]) {
        selectedSchedule = days
        updateScheduleSubtitle()
        updateCreateButtonState()
    }
}

// MARK: - UICollectionViewDelegate
extension CreateHabitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeaderView
            
            if indexPath.section == 0 {
                headerView.configure(with: "Emoji")
            } else {
                headerView.configure(with: "Цвет")
            }
            
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedEmoji = emojies[indexPath.item]
        } else {
            selectedColor = colors[indexPath.item].1
        }
        
        collectionView.reloadData()
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CreateHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}


// MARK: - UICollectionViewDataSource
extension CreateHabitViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? emojies.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiColorCell", for: indexPath) as! EmojiColorCell
        
        if indexPath.section == 0 {
            let emoji = emojies[indexPath.item]
            let isSelected = emoji == selectedEmoji
            cell.configureEmoji(with: emoji, isSelected: isSelected)
        } else {
            let colorData = colors[indexPath.item]
            let isSelected = colorData.1 == selectedColor
            cell.configureColor(with: colorData.1, isSelected: isSelected)
        }
        
        return cell
    }
    
    
}


#Preview {
    CreateHabitViewController()
}
