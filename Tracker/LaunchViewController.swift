import UIKit

final class LaunchViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLaunchView()
        }
    
    private func setupLaunchView() {
        view.backgroundColor = UIColor(named: "Blue")
        
        let logoImageView = UIImageView(image: UIImage(named: "logo"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 91),
            logoImageView.heightAnchor.constraint(equalToConstant: 94)
        ])
    }
}
