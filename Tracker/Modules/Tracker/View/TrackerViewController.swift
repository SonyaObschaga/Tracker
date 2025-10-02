import UIKit

// MARK: - TrackerViewController
final class TrackerViewController: UIViewController {
    
    // MARK: - Private Properties
    private let datePicker = UIDatePicker()
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
    }
    
    // MARK: - Actions
    @objc private func addTrackerTapped() {
        let createHabitVC = CreateHabitController()
        present(createHabitVC, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
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
}
