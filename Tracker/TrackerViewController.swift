import UIKit

final class TrackerViewController: UIViewController {
    private let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(
            image: UIImage(named: "add_tracker"),
            style: .plain,
            target: self,
            action: #selector(addTrackerTapped)
        )
        
        navigationItem.leftBarButtonItem = addButton
        addButton.tintColor = UIColor(named: "YPBlack [day]")
        setupDatePickerForNavigationBar()
    }
    
    @objc private func addTrackerTapped() {
        
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
