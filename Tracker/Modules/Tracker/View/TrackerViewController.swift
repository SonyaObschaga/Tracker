import UIKit

// MARK: - TrackerViewController
class TrackerViewController: UIViewController {
    
    // MARK: - UI Elements
    private let searchBar = UISearchBar()
    private let contentView = UIView()
    private let placeholderStackView = UIStackView()
    private let placeholderImageView = UIImageView()
    private let placeholderLabel = UILabel()
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
    private var isSearching: Bool {
        guard let searchText = searchBar.text else { return false }
        return !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
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
        loadCategories()
        reloadData()
        loadCompletedTrackers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsManager.shared.trackEvent(.screenOpen(.main))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AnalyticsManager.shared.trackEvent(.screenClose(.main))
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
    
    private func loadCategories() {
        categories = trackerCategoryStore?.fetchCategories() ?? []
    }
    
    // MARK: - Actions
    @objc private func plusButtonTapped() {
        AnalyticsManager.shared.trackEvent(.buttonClick(.main, item: .addTrack))
        loadCategories()
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
        let filterText = (searchBar.text ?? "").lowercased().trimmingCharacters(in: .whitespaces)
        let calendar = Calendar.current
        let weekdayFromCalendar = calendar.component(.weekday, from: currentDate)
        let filterWeekday: Int = weekdayFromCalendar == 1 ? 7 : weekdayFromCalendar - 1
        
        guard let allCategories = trackerCategoryStore?.fetchCategories() else {
            visibleCategories = []
            categories = []
            collectionView.reloadData()
            updatePlaceholderVisibility()
            return
        }
        
        categories = allCategories
        
        visibleCategories = allCategories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                guard let schedule = tracker.schedule else { return false }
                let weekday = Weekday(rawValue: filterWeekday) ?? .monday
                let weekdayCondition = schedule.contains(weekday)
                
                guard !filterText.isEmpty else {
                    return weekdayCondition
                }
                
                let titleMatches = tracker.title.lowercased().contains(filterText)
                let categoryMatches = category.title.lowercased().contains(filterText)
                
                return weekdayCondition && (titleMatches || categoryMatches)
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
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        let plusButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(plusButtonTapped)
        )
        plusButton.tintColor = .label
        
        navigationItem.leftBarButtonItem = plusButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        self.datePicker = datePicker
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "search".localized
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
        titleLabel.text = "trackers".localized
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
        placeholderStackView.spacing = 8
        
        placeholderImageView.contentMode = .scaleAspectFit
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
        ])
        
        placeholderLabel.textAlignment = .center
        placeholderLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textColor = .label
        
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(placeholderStackView)
        
        NSLayoutConstraint.activate([
            placeholderStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        updatePlaceholderState()
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
        
        if isEmpty {
            updatePlaceholderState()
        }
    }
    
    private func updatePlaceholderState() {
        if isSearching {
            placeholderImageView.image = UIImage(named: "nothing_smile")
            placeholderLabel.text = "nothing_found".localized
        } else {
            placeholderImageView.image = UIImage(named: "dizzy")
            placeholderLabel.text = "what_to_track".localized
        }
    }
    
    // MARK: - Context Menu
    private func editTracker(at indexPath: IndexPath) {
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.item]
        
        loadCategories()
        
        guard let fullCategory = categories.first(where: { $0.title == category.title }) else { return }

        let editVC = CreateHabitViewController()
        editVC.delegate = self
        editVC.categories = categories
        editVC.editingTracker = tracker
        editVC.editingCategory = fullCategory
        present(editVC, animated: true)
    }
    
    private func deleteTracker(at indexPath: IndexPath) {
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.item]
        
        let alert = UIAlertController(
            title: "confirm_tracker_deletion".localized,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "delete_question".localized, style: .destructive) { [weak self] _ in
            self?.performTrackerDeletion(tracker: tracker, category: category)
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        if let popover = alert.popoverPresentationController {
            if let cell = collectionView.cellForItem(at: indexPath) {
                popover.sourceView = cell
                popover.sourceRect = cell.bounds
            }
        }
        
        present(alert, animated: true)
    }
    
    private func performTrackerDeletion(tracker: Tracker, category: TrackerCategory) {
        do {
            try trackerCategoryStore?.deleteTracker(tracker.id, fromCategory: category.title)
            
            try? trackerRecordStore?.deleteRecords(for: tracker.id)
            
            reloadData()
            loadCompletedTrackers()
        } catch {
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
    
    private func createContextMenu(for indexPath: IndexPath) -> UIMenu {
        let editAction = UIAction(
            title: "edit".localized,
            image: nil
        ) { [weak self] _ in
            self?.editTracker(at: indexPath)
        }
        
        let deleteAction = UIAction(
            title: "delete".localized,
            image: nil,
            attributes: .destructive
        ) { [weak self] _ in
            self?.deleteTracker(at: indexPath)
        }
        
        return UIMenu(title: "", children: [editAction, deleteAction])
    }
}

// MARK: - UISearchBarDelegate
extension TrackerViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        applyDateFilter()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyDateFilter()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        applyDateFilter()
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
        AnalyticsManager.shared.trackEvent(.buttonClick(.main, item: .track))
        
        let today = Date()
        let calendar = Calendar.current
        if calendar.isDate(currentDate, inSameDayAs: today) || currentDate < today {
            do {
                try trackerRecordStore?.addRecord(trackerId: id, date: currentDate)
                let trackerRecord = TrackerRecord(trackerId: id, date: currentDate)
                completedTrackers.append(trackerRecord)
                
                updateCellState(at: indexPath, trackerId: id)
            } catch {
                assertionFailure(error.localizedDescription)
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
                assertionFailure(error.localizedDescription)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AnalyticsManager.shared.trackEvent(.buttonClick(.main, item: .track))
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let identifier = "\(indexPath.section)-\(indexPath.item)" as NSString
        
        return UIContextMenuConfiguration(
            identifier: identifier,
            previewProvider: nil
        ) { [weak self] _ in
            return self?.createContextMenu(for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let identifier = configuration.identifier as? String else { return nil }
        
        let components = identifier.split(separator: "-").compactMap { Int($0) }
        if components.count == 2 {
            let indexPath = IndexPath(item: components[1], section: components[0])
            if let cell = collectionView.cellForItem(at: indexPath) {
                let parameters = UIPreviewParameters()
                parameters.backgroundColor = .clear
                return UITargetedPreview(view: cell, parameters: parameters)
            }
        }
        
        return nil
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
        do {
            try trackerCategoryStore?.addTracker(tracker, toCategory: category.title)
            reloadData()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
    func didUpdateTracker(_ tracker: Tracker, in category: TrackerCategory) {
        do {
            loadCategories()
            
            if let oldCategory = categories.first(where: { cat in
                cat.trackers.contains { $0.id == tracker.id }
            }), oldCategory.title != category.title {
                try trackerCategoryStore?.deleteTracker(tracker.id, fromCategory: oldCategory.title)
                try trackerCategoryStore?.addTracker(tracker, toCategory: category.title)
            } else {
                guard let oldTracker = categories.first(where: { cat in
                    cat.trackers.contains { $0.id == tracker.id }
                })?.trackers.first(where: { $0.id == tracker.id }) else {
                    return
                }
                try trackerCategoryStore?.updateTracker(oldTracker, to: tracker, inCategory: category.title)
            }
            reloadData()
            loadCategories()
        } catch {
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
}

// MARK: - TrackerStoreDelegate
extension TrackerViewController: TrackerStoreDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        applyDateFilter()
    }
}
