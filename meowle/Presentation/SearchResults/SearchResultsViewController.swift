//
//  SearchResultsViewController.swift
//  meowle
//
//  Created by a.gorshchak on 03.02.2024.
//

import UIKit

private extension String {
    static let searchCellReuseId = "searchResultCell"
}

final class SearchResultsViewController: UIViewController {
    
    // UI
    private lazy var emptyView: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(named: "wearyCat"))
        let label = UILabel()
        label.text = isFavorites ? "Тут пока ничего нет" : "Упс! Ничего не нашли"
        label.textAlignment = .center
        
        [imageView,
         label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        if !isFavorites {
            let addCatButton = UIButton(configuration: .bordered())
            addCatButton.setTitle("Хотите добавить нового котика в базу?", for: .normal)
            addCatButton.addTarget(self, action: #selector(didTapAddCat), for: .touchUpInside)
            addCatButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(addCatButton)
            
            NSLayoutConstraint.activate([
                addCatButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                addCatButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16)
            ])
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchResultsCell.self, forCellReuseIdentifier: .searchCellReuseId)
        return tableView
    }()
    
    // Private
    private let networkService: NetworkService
    private lazy var cache = FavCache()
    private let imageResolversFactory: ImageResolversFactory
    private let data: [CatsGroup]
    private let isFavorites: Bool
    
    // MARK: - Initaialization
    
    init(
        networkService: NetworkService,
        imageResolversFactory: ImageResolversFactory,
        data: [CatsGroup],
        isFavorite: Bool = false
    ) {
        self.networkService = networkService
        self.imageResolversFactory = imageResolversFactory
        self.data = data
        self.isFavorites = isFavorite
        super.init(nibName: nil, bundle: nil)
        if isFavorite {
            title = "Избранное"
            tabBarItem = .init(title: "Избранное", image: UIImage(systemName: "star.fill"), tag: 3)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = "searchResultsViewController"
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        emptyView.isHidden = !(isFavorites ? cache.fetchAll().isEmpty : data.isEmpty)
    }
    
    // MARK: - Private
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.frame = view.frame
        view.addSubview(emptyView)
        NSLayoutConstraint.activate([
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        emptyView.isHidden = !(isFavorites ? cache.fetchAll().isEmpty : data.isEmpty)
    }
    
    @objc
    private func didTapAddCat(_ sender: UIButton) {
        navigationController?.tabBarController?.selectedIndex = 2
        navigationController?.popViewController(animated: false)
    }
}

// MARK: - UITableViewDataSource

extension SearchResultsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cat = isFavorites ? cache.fetchAll()[indexPath.row] : data[indexPath.section].cats[indexPath.row]
        let semaphore = DispatchSemaphore(value: 0)
        networkService.loadCat(by: cat.id) { result in
            switch result {
            case .success(let newCat):
                cat = newCat
            case .failure:
                break
            }
            semaphore.signal()
        }
        semaphore.wait()
        let vc = CatViewController(
            networkService: networkService,
            imageResolver: imageResolversFactory.buildImageResolver(),
            cat: cat
        )
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension SearchResultsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFavorites {
            return 1
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFavorites {
            return cache.fetchAll().count
        }
        return data[section].cats.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .searchCellReuseId, for: indexPath)
        cell.selectionStyle = .none
        if let cell = cell as? SearchResultsCell {
            let cat = isFavorites ? cache.fetchAll()[indexPath.row] : data[indexPath.section].cats[indexPath.row]
            cell.textLabel?.text = cat.name
            cell.detailTextLabel?.text = cat.description
        }
        return cell
    }
}
