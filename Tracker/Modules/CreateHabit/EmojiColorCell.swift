import UIKit

final class EmojiColorCell: UICollectionViewCell {
    
    private let emojiLabel = UILabel()
    private let colorView = UIView()
    private let selectionView = UIView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.text = nil
        emojiLabel.isHidden = true
        colorView.backgroundColor = .clear
        colorView.isHidden = true
        selectionView.backgroundColor = .clear
        selectionView.layer.borderWidth = 0
        selectionView.layer.borderColor = UIColor.clear.cgColor
        backgroundColor = .clear
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionView.backgroundColor = .clear
        selectionView.layer.cornerRadius = 8
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        
        setupselectionView()
        setupEmojiView()
        setupColorView()
    }
    
    private func setupEmojiView() {
        emojiLabel.font = .systemFont(ofSize: 32)
        emojiLabel.textAlignment = .center
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func setupColorView() {
        colorView.layer.cornerRadius = 8
        
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            colorView.heightAnchor.constraint(equalTo: colorView.widthAnchor)
        ])
    }
    
    private func setupselectionView() {
        selectionView.backgroundColor = .clear
        selectionView.layer.cornerRadius = 8
        
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectionView)
        
        NSLayoutConstraint.activate([
            selectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configureEmoji(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        emojiLabel.isHidden = false
        colorView.isHidden = true
        
        if isSelected {
            selectionView.backgroundColor = .systemGray6
            selectionView.layer.borderWidth = 0
            selectionView.layer.borderColor = UIColor.clear.cgColor
        } else {
            selectionView.backgroundColor = .clear
            selectionView.layer.borderWidth = 0
            selectionView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func configureColor(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        colorView.isHidden = false
        emojiLabel.isHidden = true
        
        if isSelected {
            selectionView.backgroundColor = .systemGray6
            selectionView.layer.borderWidth = 3
            selectionView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            selectionView.backgroundColor = .clear
            selectionView.layer.borderWidth = 0
            selectionView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}

