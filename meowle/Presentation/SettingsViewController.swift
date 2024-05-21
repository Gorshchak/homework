//
//  SettingsViewController.swift
//  meowle
//
//  Created by a.gorshchak on 05.03.2024.
//

import UIKit

protocol SettingsOutput: AnyObject {
    func didLogout()
}

final class SettingsViewController: UIViewController {
    
    weak var output: SettingsOutput?
    
    // UI
    private let helloLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var logoutButton: UIButton = {
        let button = UIButton(configuration: .bordered())
        button.setTitle("Выйти из аккаунта", for: .normal)
        button.accessibilityIdentifier = "logOutFromApplication"
        button.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        tabBarItem = .init(
            title: "Настройки",
            image: UIImage(systemName: "gear"),
            tag: 3
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = "settingsScreenViewController"
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        helloLabel.text = "Привет, \(UserDefaults.standard.string(forKey: "username") ?? "username")!"
    }
    
    // MARK: - Private
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(helloLabel)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            helloLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            helloLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            helloLabel.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -16)
        ])
    }
    
    @objc
    private func didTapLogout(_ sender: UIButton) {
        guard sender === logoutButton else { return }
        output?.didLogout()
    }
}
