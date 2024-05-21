//
//  AuthViewController.swift
//  meowle
//
//  Created by a.gorshchak on 05.03.2024.
//

import UIKit

protocol AuthOutput: AnyObject {
    func didAuth(as username: String)
}

final class AuthViewController: UIViewController {
    
    weak var output: AuthOutput?
    
    // UI
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Авторизация"
        label.font = .systemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Введите своё имя"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    private lazy var authButton: UIButton = {
        let button = UIButton(configuration: .bordered())
        button.setTitle("Войти", for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = "authScreenViewController"
        setupUI()
    }
    
    // MARK: - Private
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(label)
        view.addSubview(textField)
        view.addSubview(authButton)
        
        NSLayoutConstraint.activate([
            label.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -32),
            label.centerXAnchor.constraint(equalTo: textField.centerXAnchor),
            
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            
            authButton.centerXAnchor.constraint(equalTo: textField.centerXAnchor),
            authButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            authButton.widthAnchor.constraint(lessThanOrEqualTo: textField.widthAnchor)
        ])
        
    }
    
    @objc
    private func didTapButton(_ sender: UIButton) {
        guard sender === authButton else { return }
        if let username = textField.text,
           !username.isEmpty {
            dismiss(animated: true)
            output?.didAuth(as: username)
        } else {
            textField.backgroundColor = .systemRed.withAlphaComponent(0.3)
        }
    }
}
