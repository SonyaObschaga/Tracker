import UIKit

// MARK: - TrackerViewController
final class TrackerViewController: UIViewController {
    
    // MARK: - Private Properties
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var trackers: [Tracker] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate = Date()
    private var onPlusTapped: (() -> Void)?
    private var isCompletedToday: Bool = false
    private var indexPath: IndexPath?
    private var trackerId: UUID?
    private var tracker: Tracker?
    
    // MARK: - UI Elements
    private let datePicker = UIDatePicker()
    private let centerImageView = UIImageView()
    private let centerLabel = UILabel()
    private let mainLabel = UILabel()
    let searchBar = UISearchBar()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeaderView"
        )
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        updatePlaceholderVisibility()
        setupTestData()
    }
    
    // MARK: - Actions
    @objc private func addTrackerTapped() {
        let createHabitVC = CreateHabitViewController()
        createHabitVC.delegate = self
        present(createHabitVC, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = .ypBackgroundDay
        setupCenterImage()
        setupCenterLabel()
        setupMainLabel()
        setupSearchBar()
    }
    
    private func setupCenterImage() {
        centerImageView.image = UIImage(named: "dizzy")
        centerImageView.contentMode = .scaleAspectFit
        centerImageView.isHidden = false
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(centerImageView)
        
        NSLayoutConstraint.activate([
            centerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerImageView.widthAnchor.constraint(equalToConstant: 80),
            centerImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setupCenterLabel() {
        centerLabel.text = "Что будем отслеживать?"
        centerLabel.textAlignment = .center
        centerLabel.numberOfLines = 0
        centerLabel.textColor = UIColor(named: "YPBlack [day]")
        centerLabel.isHidden = false
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if let sfProFont = UIFont(name: "SFProText-Medium", size: 12) {
            centerLabel.font = sfProFont
        } else {
            centerLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        }
        view.addSubview(centerLabel)
        
        NSLayoutConstraint.activate([
            centerLabel.topAnchor.constraint(equalTo: centerImageView.bottomAnchor, constant: 8),
            centerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            centerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupMainLabel() {
        mainLabel.text = "Трекеры"
        mainLabel.textColor = UIColor(named: "YPBlack [day]")
        mainLabel.numberOfLines = 0
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if let sfProFont = UIFont(name: "SFProText-Bold", size: 34) {
            mainLabel.font = sfProFont
        } else {
            mainLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        }
        
        view.addSubview(mainLabel)
        
        NSLayoutConstraint.activate([
            mainLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            mainLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar.searchTextField.font = UIFont.systemFont(ofSize: 17)
        searchBar.searchTextField.textColor = UIColor(named: "YPGray")
        
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupNavigationBar() {
        setupAddTrackerButton()
        setupDatePickerForNavigationBar()
    }
    
    private func setupAddTrackerButton() {
        let addButton = UIBarButtonItem(
            image: UIImage(named: "add_tracker"),
            style: .plain,
            target: self,
            action: #selector(addTrackerTapped)
        )
        
        navigationItem.leftBarButtonItem = addButton
        addButton.tintColor = UIColor(named: "YPBlack [day]")
    }
    
    private func setupDatePickerForNavigationBar() {
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(datePicker)
        
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        
        datePicker.widthAnchor.constraint(equalToConstant: 77).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        navigationItem.rightBarButtonItem = datePickerItem
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 64),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: view.frame.height - 148),
        ])
    }
    
    func configure(
        with tracker: Tracker,
        category: String,
        onPlusTapped: @escaping () -> Void,
        isCompletedToday: Bool,
        completedDays: Int,
        indexPath: IndexPath
    ) {
        self.indexPath = indexPath
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.tracker = tracker
        self.onPlusTapped = onPlusTapped
        
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        emojiView.backgroundColor = tracker.color
        
    }
    
    private func updatePlaceholderVisibility() {
        let hasTrackers = !visibleCategories.isEmpty
        centerLabel.isHidden = hasTrackers
        centerImageView.isHidden = hasTrackers
        collectionView.isHidden = !hasTrackers
    }
    
    private func findOrCreateCategory(named categoryName: String) -> TrackerCategory {
        if let existingCategory = categories.first(where: { $0.title == categoryName }) {
            return existingCategory
        } else {
            let newCategory = TrackerCategory(title: categoryName, trackers: [])
            categories.append(newCategory)
            return newCategory
        }
    }
    
    private func setupTestData() {
        let tracker1 = Tracker(
            id: UUID(),
            title: "Поливать растения",
            color: .ypBlue,
            emoji: "🌿",
            schedule: [.monday, .wednesday]
        )
        
        let tracker2 = Tracker(
            id: UUID(),
            title: "Собрать яблоки",
            color: .ypGray,
            emoji: "🍎",
            schedule: [.sunday, .tuesday, .thursday]
        )
        
        let tracker3 = Tracker(
            id: UUID(),
            title: "Сходить в магазин",
            color: .ypRed,
            emoji: "🛒",
            schedule:  [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        )
        
        trackers = [tracker1, tracker2, tracker3]
        
        let habitCategory = TrackerCategory(title: "Важное", trackers: [tracker1])
        
        let eventCategory = TrackerCategory(title: "Моё время", trackers: [tracker2, tracker3])
        
        categories = [habitCategory, eventCategory]
        
        applyDateFilter()
        
    }
    
    private func applyDateFilter() {
        let filterText = (searchBar.text ?? "").lowercased()
        let calendar = Calendar.current
        let weekdayFromCalendar = calendar.component(.weekday, from: currentDate)
        
        let filterWeekday: Int
        if weekdayFromCalendar == 1 {
            filterWeekday = 7
        } else {
            filterWeekday = weekdayFromCalendar - 1
        }
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty || tracker.title.lowercased().contains(filterText)
                guard let schedule = tracker.schedule else { return false }
                let weekday = Weekday(rawValue: filterWeekday) ?? .monday
                return schedule.contains(weekday) && textCondition
            }
            
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(title: category.title, trackers: trackers)
        }
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    private func handleTrackerPlusTapped() {
        print("Tracker plus tapped")
    }
}

extension TrackerViewController: CreateHabitDelegate {
    func didCreateNewTracker(_ tracker: Tracker, category: String) {
        let categoryToUpdate = findOrCreateCategory(named: category)
        
        if let index = categories.firstIndex(where: { $0.title == categoryToUpdate.title }) {
            var updatedTrackers = categories[index].trackers
            updatedTrackers.append(tracker)
            categories[index] = TrackerCategory(title: categoryToUpdate.title, trackers: updatedTrackers)
        }
        
        updatePlaceholderVisibility()
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.item]
        
        cell.delegate = self
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count
        cell.configure(
            with: tracker,
            category: category.title,
            onPlusTapped: { [weak self] in
                self?.handleTrackerPlusTapped()
            },
            isCompletedToday: isCompletedToday,
            completedDays: completedDays,
            indexPath: indexPath
        )
        
        return cell
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        return completedTrackers.contains { TrackerRecord in
            isSameTrackerRecord(trackerRecord: TrackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: currentDate)
        return trackerRecord.trackerId == id && isSameDay
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind:kind,
            withReuseIdentifier: "SectionHeaderView",
            for: indexPath
        ) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        
        header.configure(with: "Trackers")
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - 12
        let width = availableWidth / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    }
}

// MARK: - TrackerCellDelegate
extension TrackerViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let today = Date()
        let calendar = Calendar.current
        if calendar.isDate(currentDate, inSameDayAs: today)
            || currentDate < today
        {
            let trackerRecord = TrackerRecord(trackerId: id, date: currentDate)
            completedTrackers.append(trackerRecord)
            
            if let cell = collectionView.cellForItem(at: indexPath)
                as? TrackerCell
            {
                let isCompletedToday = isTrackerCompletedToday(id: id)
                let completedDays = completedTrackers.filter {
                    $0.trackerId == id
                }.count
                cell.updateButtonState(
                    isCompletedToday: isCompletedToday,
                    completedDays: completedDays
                )
            }
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        let today = Date()
        let calendar = Calendar.current
        if calendar.isDate(currentDate, inSameDayAs: today)
            || currentDate < today
        {
            completedTrackers.removeAll { TrackerRecord in
                isSameTrackerRecord(trackerRecord: TrackerRecord, id: id)
            }
            
            if let cell = collectionView.cellForItem(at: indexPath)
                as? TrackerCell
            {
                let isCompletedToday = isTrackerCompletedToday(id: id)
                let completedDays = completedTrackers.filter {
                    $0.trackerId == id
                }.count
                cell.updateButtonState(
                    isCompletedToday: isCompletedToday,
                    completedDays: completedDays
                )
            }
        }
    }
}
