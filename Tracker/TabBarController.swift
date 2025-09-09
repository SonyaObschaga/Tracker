import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
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
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "White")
    }
    
}

