//
//  RatingViewController.swift
//  meowle
//
//  Created by a.gorshchak on 20.01.2024.
//

import UIKit

private extension String {
    static let ratingCellReuseId = "ratingCell"
}

final class RatingViewController: UIViewController {
    
    // UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RatingCell.self, forCellReuseIdentifier: .ratingCellReuseId)
        return tableView
    }()
    
    // Private
    private var imagesList: [Int: [URL]] = [:]
    private var data: RatingResponse = RatingResponse(likes: [], dislikes: []) {
        didSet {
            let list = Set<Int>((data.likes.map(\.id) + data.dislikes.map(\.id)))
            list.enumerated().forEach { [weak self] offset, id in
                self?.networkService.loadCatPhotosList(by: id, { result in
                    switch result {
                    case .success(let list):
                        self?.imagesList[id] = list
                    case .failure(let error):
                        print(error)
                    }
                    if offset == list.count - 1 {
                        DispatchQueue.performOnMain {
                            self?.tableView.reloadData()
                        }
                    }
                })
            }
        }
    }
    
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
            title: "Рейтинг",
            image: UIImage(systemName: "star.circle"),
            tag: 1
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = "ratingViewController"
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        networkService.loadRating { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.performOnMain {
                    self?.data = data
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Private
    
    private func setupUI() {
        navigationController?.navigationBar.items?.first?.title = "Рейтинг имён котиков"
        view.backgroundColor = .yellow
        view.addSubview(tableView)
        tableView.frame = view.frame
    }
}

// MARK: - UITableViewDataSource

extension RatingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let catId: Int = {
            switch indexPath.section {
            case 0:
                return data.likes[indexPath.row].id
            case 1:
                return data.dislikes[indexPath.row].id
            default:
                return nil
            }
        }() else { return }
        
        networkService.loadCat(by: catId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let cat):
                DispatchQueue.performOnMain {
                    let vc = CatViewController(
                        networkService: self.networkService,
                        imageResolver: self.imageResolversFactory.buildImageResolver(),
                        cat: cat
                    )
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension RatingViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return data.likes.count
        case 1:
            return data.dislikes.count
        default:
            return .zero
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: .ratingCellReuseId,
            for: indexPath
        )
        if let cell = cell as? RatingCell {
            if cell.imageResolver == nil {
                cell.imageResolver = imageResolversFactory.buildImageResolver()
            }
            if indexPath.section == 0 {
                let model = data.likes[indexPath.row]
                cell.configure(
                    number: indexPath.row + 1,
                    imageUrl: imagesList[model.id]?.first,
                    name: model.name,
                    isPositive: true,
                    ratingCount: model.likes
                )
            } else {
                let model = data.dislikes[indexPath.row]
                cell.configure(
                    number: indexPath.row + 1,
                    imageUrl: imagesList[model.id]?.first,
                    name: model.name,
                    isPositive: false,
                    ratingCount: model.dislikes
                )
            }
        }
        return cell
    }
}
