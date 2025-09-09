import UIKit

final class TabBarController: UITabBarController {
    
    private let centerImageView = UIImageView()
    private let centerLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupTabBarAppearance()
        setupUI()
    }
    
    private func setupViewControllers() {
        let trackerVC = TrackerViewController()
        let statisticVC = StatisticViewController()
        
        trackerVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "record_circle"),
            selectedImage: UIImage(named: "record.circle.fill")
        )
        
        statisticVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare"),
            selectedImage: UIImage(systemName: "hare.fill")
        )
        
        viewControllers = [trackerVC, statisticVC]
    }
    
    private func setupUI() {
        setupCenterImage()
        setupCenterLabel()
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "White")
    }
    
    private func setupCenterImage() {
        centerImageView.image = UIImage(named: "dizzy")
        centerImageView.contentMode = .scaleAspectFit
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
        centerLabel.textColor = UIColor(named: "Black [day]")
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
    
}

