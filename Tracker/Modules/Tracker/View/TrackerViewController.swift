import UIKit

// MARK: - TrackerViewController
class TrackerViewController: UIViewController {
    
    // MARK: - UI Elements
    private let searchBar = UISearchBar()
    private let contentView = UIView()
    private let placeholderStackView = UIStackView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private var dateButton = UIButton()
    private let plusImage = UIImage(named: "add_tracker")
    private var datePicker: UIDatePicker?
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 16,right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    // MARK: -  Private Properties
    private var trackers: [Tracker] = []
    private var visibleCategories: [TrackerCategory] = []
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date
    private var trackerStore: TrackerStore?
    private var trackerRecordStore: TrackerRecordStore?
    private var trackerCategoryStore: TrackerCategoryStore?
    
    // MARK: - Initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        currentDate = Date()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        currentDate = Date()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStores()
        setupUI()
        reloadData()
        loadCompletedTrackers()
    }
    
    // MARK: - TrackerStore Setup
    private func setupStores() {
        trackerStore = TrackerStore()
        trackerStore?.delegate = self
        trackerRecordStore = TrackerRecordStore()
        trackerCategoryStore = TrackerCategoryStore()
    }
    
    private func loadCompletedTrackers() {
        completedTrackers = (try? trackerRecordStore?.fetchRecords()) ?? []
    }
    
    // MARK: - Actions
    @objc private func plusButtonTapped() {
        let createHabitVC = CreateHabitViewController()
        createHabitVC.delegate = self
        createHabitVC.categories = categories
        present(createHabitVC, animated: true)
    }
    
    @objc private func dateChanged() {
        currentDate = datePicker?.date ?? Date()
        applyDateFilter()
    }
    
    //MARK: - Private Methods
    private func reloadData() {
        applyDateFilter()
    }
    
    private func applyDateFilter() {
        let filterText = (searchBar.text ?? "").lowercased()
        let calendar = Calendar.current
        let weekdayFromCalendar = calendar.component(.weekday, from: currentDate)
        let filterWeekday: Int = weekdayFromCalendar == 1 ? 7 : weekdayFromCalendar - 1
        
        guard let allCategories = trackerCategoryStore?.fetchCategories() else {
            visibleCategories = []
            collectionView.reloadData()
            updatePlaceholderVisibility()
            return
        }
        
        visibleCategories = allCategories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty || tracker.title.lowercased().contains(filterText)
                guard let schedule = tracker.schedule else { return false }
                let weekday = Weekday(rawValue: filterWeekday) ?? .monday
                return schedule.contains(weekday) && textCondition
            }
            
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    private func handleTrackerPlusTapped() {
        print("Tracker plus tapped")
    }
    
    // MARK: - SetupUI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupTitleLabel()
        setupSearchBar()
        setupContentView()
        setupPlaceholderStackView()
        setupCollectionView()
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        let plusButton = UIButton(type: .custom)
        plusButton.setImage(plusImage, for: .normal)
        plusButton.tintColor = .label
        
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        self.datePicker = datePicker
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Поиск"
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        searchBar.barTintColor = .clear
        searchBar.isTranslucent = true
        searchBar.delegate = self
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16)
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Трекеры"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .left
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16),
        ])
    }
    
    private func setupContentView() {
        contentView.backgroundColor = .systemBackground
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupPlaceholderStackView() {
        placeholderStackView.translatesAutoresizingMaskIntoConstraints = false
        placeholderStackView.axis = .vertical
        placeholderStackView.alignment = .center
        placeholderStackView.spacing = 16
        
        let placeholderImage = UIImageView(image: UIImage(named: "dizzy"))
        placeholderImage.contentMode = .scaleAspectFit
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
        ])
        
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Что будем отслеживать?"
        placeholderLabel.textAlignment = .center
        placeholderLabel.font = UIFont.systemFont(ofSize: 17)
        placeholderLabel.textColor = .label
        
        placeholderStackView.addArrangedSubview(placeholderImage)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(placeholderStackView)
        
        NSLayoutConstraint.activate([
            placeholderStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    //MARK: - Private Methods
    private func updatePlaceholderVisibility() {
        let isEmpty = visibleCategories.isEmpty
        
        placeholderStackView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        
    }
}

// MARK: - UISearchBarDelegate
extension TrackerViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        applyDateFilter()
        searchBar.resignFirstResponder()
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
        let completedDays = completedTrackers.filter {
            $0.trackerId == tracker.id
        }.count
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
}

// MARK: - TrackerCellDelegate
extension TrackerViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let today = Date()
        let calendar = Calendar.current
        if calendar.isDate(currentDate, inSameDayAs: today) || currentDate < today {
            do {
                try trackerRecordStore?.addRecord(trackerId: id, date: currentDate)
                let trackerRecord = TrackerRecord(trackerId: id, date: currentDate)
                completedTrackers.append(trackerRecord)
                
                updateCellState(at: indexPath, trackerId: id)
            } catch {
                print("Ошибка сохранения выполнения трекера: \(error)")
            }
        }
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        let today = Date()
        let calendar = Calendar.current
        if calendar.isDate(currentDate, inSameDayAs: today) || currentDate < today {
            do {
                try trackerRecordStore?.removeRecord(trackerId: id, date: currentDate)
                completedTrackers.removeAll { trackerRecord in
                    isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
                }
                
                updateCellState(at: indexPath, trackerId: id)
            } catch {
                print("Ошибка удаления выполнения трекера: \(error)")
            }
        }
    }
    
    private func updateCellState(at indexPath: IndexPath, trackerId: UUID) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell {
            let isCompletedToday = isTrackerCompletedToday(id: trackerId)
            let completedDays = completedTrackers.filter { $0.trackerId == trackerId }.count
            cell.updateButtonState(isCompletedToday: isCompletedToday, completedDays: completedDays)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension TrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeaderView else {
                return UICollectionReusableView()
            }
            
            let category = visibleCategories[indexPath.section]
            headerView.configure(with: category.title)
            return headerView
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 48) / 2
        return CGSize(width: width, height: 148)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 18)
    }
}

// MARK: - CreateHabitDelegate
extension TrackerViewController: CreateHabitDelegate {
    func didCreateTracker(_ tracker: Tracker, in category: TrackerCategory) {
        if let categoryIndex = categories.firstIndex(where: {
            $0.title == category.title
        }) {
            let oldCategory = categories[categoryIndex]
            let updatedTrackers = oldCategory.trackers + [tracker]
            let updatedCategory = TrackerCategory(
                title: oldCategory.title,
                trackers: updatedTrackers
            )
            categories[categoryIndex] = updatedCategory
        } else {
            let newCategory = TrackerCategory(
                title: "Важно",
                trackers: [tracker]
            )
            categories.append(newCategory)
        }
        
        applyDateFilter()
    }
}

// MARK: - TrackerStoreDelegate
extension TrackerViewController: TrackerStoreDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        applyDateFilter()
    }
}
