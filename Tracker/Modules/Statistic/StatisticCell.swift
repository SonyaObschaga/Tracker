import UIKit

final class StatisticCell: UICollectionViewCell {
    private let containerView = UIView()
    private let numberLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let gradientLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutGradientBorder()
    }
    
    func configure(numberText: String, descriptionText: String) {
        numberLabel.text = numberText
        descriptionLabel.text = descriptionText
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        numberLabel.font = .systemFont(ofSize: 34, weight: .bold)
        numberLabel.textColor = .label
        numberLabel.textAlignment = .left
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        descriptionLabel.textColor = .label
        descriptionLabel.textAlignment = .left
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(numberLabel)
        containerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),
            
            numberLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            numberLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            numberLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 7),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
        
        gradientLayer.colors = [
            UIColor(red: 0.0/255.0, green: 123.0/255.0, blue: 250.0/255.0, alpha: 1).cgColor, // #007BFA
            UIColor(red: 70.0/255.0, green: 230.0/255.0, blue: 157.0/255.0, alpha: 1).cgColor, // #46E69D
            UIColor(red: 253.0/255.0, green: 76.0/255.0, blue: 73.0/255.0, alpha: 1).cgColor   // #FD4C49
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0, 0.5, 1]
        contentView.layer.addSublayer(gradientLayer)
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1 / UIScreen.main.scale
        shapeLayer.strokeColor = UIColor.white.cgColor
        gradientLayer.mask = shapeLayer
    }
    
    private func layoutGradientBorder() {
        gradientLayer.frame = contentView.bounds
        shapeLayer.frame = gradientLayer.bounds
        let inset: CGFloat = 0.5
        let rect = contentView.bounds.insetBy(dx: inset, dy: inset)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 16)
        shapeLayer.path = path.cgPath
    }
}


