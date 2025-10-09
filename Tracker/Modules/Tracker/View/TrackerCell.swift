import UIKit

// MARK: - TrackerCell
final class TrackerCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let emojiView = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let daysLabel = UILabel()
    private let plusButton = UIButton(type: .system)
    
    // MARK: - Private Properties
    private var tracker: Tracker?
    private var onPlusTapped: (() -> Void)?
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    private let doneImage = UIImage(named: "done")
    private let unDoneImage = UIImage(named: "plus_in_tracker")
    
    weak var delegate: TrackerCellDelegate?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SetupUI
    private func setupUI() {
        backgroundColor = .clear
        setupEmojiView()
        setupEmojiLabel()
        setupTitleLabel()
        setupDaysLabel()
        setupPlusButton()
    }
    
    private func setupEmojiView() {
        emojiView.layer.cornerRadius = 12
        
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emojiView)
        
        NSLayoutConstraint.activate([
            emojiView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            emojiView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            emojiView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            emojiView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func setupEmojiLabel() {
        emojiLabel.font = .systemFont(ofSize: 16)
        emojiLabel.textAlignment = .center
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: emojiView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: emojiView.leadingAnchor, constant: 12)
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .white
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: emojiView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: emojiView.leadingAnchor, constant: 12)
        ])
    }
    
    private func setupDaysLabel() {
        daysLabel.font = .systemFont(ofSize: 12, weight: .medium)
        daysLabel.textColor = .label
        
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(daysLabel)
        
        NSLayoutConstraint.activate([
            daysLabel.topAnchor.constraint(equalTo: emojiView.bottomAnchor, constant: 16),
            daysLabel.leadingAnchor.constraint(equalTo: emojiView.leadingAnchor, constant: 12),
            daysLabel.widthAnchor.constraint(equalToConstant: 101)
        ])
    }
    
    private func setupPlusButton() {
        let image = isCompletedToday ? doneImage : unDoneImage
        plusButton.setImage(image, for: .normal)
        plusButton.tintColor = .label
        plusButton.backgroundColor = .clear
        plusButton.layer.cornerRadius = 8
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            plusButton.centerYAnchor.constraint(equalTo: daysLabel.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: emojiView.trailingAnchor,constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
    
    // MARK: - Configuration
    func configure(
        with tracker: Tracker,
        category: String,
        onPlusTapped: @escaping () -> Void,
        isCompletedToday: Bool,
        completedDays: Int,
        indexPath: IndexPath
    ) {
        self.indexPath = indexPath
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.tracker = tracker
        self.onPlusTapped = onPlusTapped
        
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        emojiView.backgroundColor = tracker.color
        plusButton.tintColor = tracker.color
        
        let wordDay = pluralizeDays(completedDays)
        daysLabel.text = "\(completedDays) \(wordDay)"
        let image = isCompletedToday ? doneImage : unDoneImage
        plusButton.setImage(image, for: .normal)
    }
    
    // MARK: - Private Method
    private func pluralizeDays(_ count: Int) -> String {
        let remainder = count % 10
        let remainder100 = count % 100
        
        if remainder100 >= 11 && remainder100 <= 19 {
            return "дней"
        } else if remainder == 1 {
            return "день"
        } else if remainder >= 2 && remainder <= 4 {
            return "дня"
        } else {
            return "дней"
        }
    }
    
    // MARK: - Public Method
    func updateButtonState(isCompletedToday: Bool, completedDays: Int) {
        self.isCompletedToday = isCompletedToday
        
        let image = isCompletedToday ? doneImage : unDoneImage
        plusButton.setImage(image, for: .normal)
        
        let wordDay = pluralizeDays(completedDays)
        daysLabel.text = "\(completedDays) \(wordDay)"
    }
    
    // MARK: - Actions
    @objc private func plusButtonTapped() {
        guard let trackerId = trackerId, let indexPath = indexPath else { return }
        
        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completetracker(id: trackerId, at: indexPath)
        }
    }
}
