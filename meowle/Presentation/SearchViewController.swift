//
//  SearchViewController.swift
//  meowle
//
//  Created by a.gorshchak on 20.01.2024.
//

import UIKit

final class SearchViewController: UIViewController {
    
    // UI
    private let searchField = {
        let textField = UITextField()
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.black.cgColor
        textField.placeholder = "Введите имя котика"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    private lazy var searchButton = {
        let button = UIButton(configuration: UIButton.Configuration.bordered())
        button.setTitle("Поиск", for: .normal)
        button.accessibilityIdentifier = "searchCatButton"
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    private lazy var allNamesButton = {
        let button = UIButton(configuration: UIButton.Configuration.bordered())
        button.setTitle("Все имена", for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    private let imageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "meowle"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Dependencies
    private let networkService: NetworkService
    private let imageResolversFactory: ImageResolversFactory
    
    // MARK: - Initaialization
    
    init(
        networkService: NetworkService,
        imageResolversFactory: ImageResolversFactory
    ) {
        self.networkService = networkService
        self.imageResolversFactory = imageResolversFactory
        super.init(nibName: nil, bundle: nil)
        tabBarItem = .init(
            title: "Поиск",
            image: UIImage(systemName: "magnifyingglass"),
            tag: .zero
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = "searchScreenViewController"
        setupUI()
    }
    
    // MARK: - Private

    private func setupUI() {
        navigationController?.navigationBar.items?.first?.title = "Meowle"
        view.backgroundColor = .systemBackground
        
        let buttonsStackView = UIStackView(arrangedSubviews: [
            searchButton,
            allNamesButton
        ])
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 16
        
        let stackView = UIStackView(arrangedSubviews: [
            searchField,
            buttonsStackView,
            imageView
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .equalSpacing
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            searchField.heightAnchor.constraint(equalToConstant: 25),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }
    
    @objc
    private func didTapButton(_ sender: UIButton) {
        switch sender {
        case searchButton:
            if let request = searchField.text,
               !request.isEmpty {
                networkService.loadSearchResults(for: request) { [weak self] result in
                    guard let self = self else {
                        DispatchQueue.performOnMain {
                            let alert = UIAlertController(
                                title: nil,
                                message: "Что-то пошло не так",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "Ок", style: .default))
                            self?.navigationController?.present(alert, animated: true)
                        }
                        return
                    }
                    switch result {
                    case .success(let data):
                        DispatchQueue.performOnMain {
                            let vc = SearchResultsViewController(
                                networkService: self.networkService,
                                imageResolversFactory: self.imageResolversFactory,
                                data: data
                            )
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    case .failure(let error):
                        DispatchQueue.performOnMain {
                            let alert = UIAlertController(
                                title: nil,
                                message: "Такие котики не найдены",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "Ладно", style: .default))
                            self.navigationController?.present(alert, animated: true)
                        }
                        print(error)
                    }
                }
            } else {
                let alert = UIAlertController(
                    title: "Так нельзя",
                    message: "Введен пустой поисковый запрос",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Извините", style: .default))
                navigationController?.present(alert, animated: true)
            }
        case allNamesButton:
            networkService.loadAllNames() { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    DispatchQueue.performOnMain {
                        let vc = SearchResultsViewController(
                            networkService: self.networkService,
                            imageResolversFactory: self.imageResolversFactory,
                            data: data
                        )
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        default:
            return
        }
    }
}
