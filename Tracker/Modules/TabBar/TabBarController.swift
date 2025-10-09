import UIKit

// MARK: - TabBarController
final class TabBarController: UITabBarController {
    
    // MARK: - UI Elements
    private let centerImageView = UIImageView()
    private let centerLabel = UILabel()
    private let mainLabel = UILabel()
    private let searchBar = UISearchBar()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupTabBarAppearance()
        setupNavigationBarAppearance()
    }
    
    // MARK: - Private Methods
    private func setupViewControllers() {
        let trackerVC = TrackerViewController()
        let statisticVC = StatisticViewController()
        
        let trackerNav = UINavigationController(rootViewController: trackerVC)
        let statisticNav = UINavigationController(rootViewController: statisticVC)
        
        trackerNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "record_circle"),
            selectedImage: nil
        )
        
        statisticNav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare"),
            selectedImage: nil
        )
        
        viewControllers = [trackerNav, statisticNav]
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "White")
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "YPBlack [day]") ?? .black,
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "White")
    }
}

