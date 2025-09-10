import UIKit

final class TrackerViewController: UIViewController {
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
        addButton.tintColor = UIColor(named: "Black [day]")
    }
    
    @objc private func addTrackerTapped() {
        
    }
}
