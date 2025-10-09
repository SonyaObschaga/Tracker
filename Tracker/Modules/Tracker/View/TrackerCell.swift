import UIKit

// MARK: - TrackerCellDelegate
protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

// MARK: - TrackerCell
final class TrackerCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhiteDay
        label.numberOfLines = 2
        return label
    }()
    
    private let daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        return label
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        
        button.addTarget(nil, action: #selector(completeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    weak var delegate: TrackerCellDelegate?
    private var tracker: Tracker?
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        
        [emojiLabel, titleLabel, daysCountLabel, completeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -44),
            
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    // MARK: - Configuration
    func configure(with tracker: Tracker, completedDays: Int, isCompletedToday: Bool) {
        let buttonColorTapped: UIColor = .ypRed
        let buttonColorDefault: UIColor = .ypBlue
        self.tracker = tracker
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        contentView.backgroundColor = .ypBlue
        
        daysCountLabel.text = "\(completedDays) дней"
        
        let buttonColor = isCompletedToday ? buttonColorTapped : buttonColorDefault
        completeButton.backgroundColor = buttonColor
        
        let buttonImage = isCompletedToday ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        completeButton.setImage(buttonImage, for: .normal)
        completeButton.tintColor = .ypWhiteDay
    }
    
    // MARK: - Actions
    @objc func completeButtonTapped() {
        guard let trackerId = trackerId, let indexPath = indexPath else { return }
        
        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
}
