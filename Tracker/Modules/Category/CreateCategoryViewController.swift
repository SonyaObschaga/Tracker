import UIKit

// MARK: - CreateCategoryViewController
final class CreateCategoryViewController: UIViewController {
    
    // MARK: - Properties
    
    //MARK: - UI Elements
    private let titleLabel = UILabel()
    private let textFieldOfCategoryName = UITextField()
    private let doneButton = UIButton()

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateCreateButtonState()
    }
    
    // MARK: - Actions
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func didTapDoneButton() {
        
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - SetupUI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupTitleLabel()
        setuptextFieldOfCategoryName()
        setupAddButton()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Новая категория"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .ypBlackDay
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setuptextFieldOfCategoryName() {
        textFieldOfCategoryName.placeholder = "Введите название категории"
        textFieldOfCategoryName.textColor = .ypBlackDay
        textFieldOfCategoryName.backgroundColor = .ypBackgroundDay
        textFieldOfCategoryName.layer.masksToBounds = true
        textFieldOfCategoryName.layer.cornerRadius = 16
        textFieldOfCategoryName.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textFieldOfCategoryName.clearButtonMode = .whileEditing
        textFieldOfCategoryName.returnKeyType = .done
        textFieldOfCategoryName.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textFieldOfCategoryName.frame.height))
        textFieldOfCategoryName.leftView = paddingView
        textFieldOfCategoryName.leftViewMode = .always
        
        textFieldOfCategoryName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textFieldOfCategoryName)
        
        NSLayoutConstraint.activate([
            textFieldOfCategoryName.heightAnchor.constraint(equalToConstant: 75),
            textFieldOfCategoryName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldOfCategoryName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textFieldOfCategoryName.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38)
        ])
    }
    
    private func setupAddButton() {
        doneButton.backgroundColor = .ypBlackDay
        doneButton.layer.masksToBounds = true
        doneButton.layer.cornerRadius = 16
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.ypWhiteDay, for: .normal)
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Private Methods
    private func updateCreateButtonState() {
        let isFormValid = !(textFieldOfCategoryName.text?.isEmpty ?? true)
        
        doneButton.isEnabled = isFormValid
        doneButton.backgroundColor = isFormValid ? .ypBlackDay : .ypGray
    }
}

#Preview {
    CreateCategoryViewController()
}
