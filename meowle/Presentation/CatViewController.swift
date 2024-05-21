//
//  CatViewController.swift
//  meowle
//
//  Created by a.gorshchak on 04.02.2024.
//

import UIKit

final class CatViewController: UIViewController {
    
    // UI
    private let newCatInfo: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = "✅ Котик успешно добавлен"
        label.textColor = .systemGreen
        view.layer.cornerRadius = 5
        view.backgroundColor = .green.withAlphaComponent(0.2)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
        ])
        return view
    }()
    private let nameView: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var descriptionView: UITextView = {
        let view = UITextView()
        view.delegate = self
        view.layer.cornerRadius = 5
        view.returnKeyType = .done
        view.backgroundColor = .lightGray.withAlphaComponent(0.15)
        view.font = .systemFont(ofSize: 17)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let likesButton: UIButton = {
        let view = UIButton(configuration: UIButton.Configuration.bordered())
        view.backgroundColor = .lightGray.withAlphaComponent(0.5)
        view.layer.cornerRadius = 5
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let dislikesButton: UIButton = {
        let view = UIButton(configuration: UIButton.Configuration.bordered())
        view.backgroundColor = .lightGray.withAlphaComponent(0.5)
        view.layer.cornerRadius = 5
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let catImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "photo")
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 10
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Private
    private let networkService: NetworkService
    private let cache = FavCache()
    private let imageResolver: ImageResolver
    private let cat: Cat
    private let isNew: Bool
    
    // MARK: - Initialization
    
    init(
        networkService: NetworkService,
        imageResolver: ImageResolver,
        cat: Cat,
        isNew: Bool = false
    ) {
        self.networkService = networkService
        self.imageResolver = imageResolver
        self.cat = cat
        self.isNew = isNew
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if navigationItem.rightBarButtonItem?.customView?.tintColor == .gray || isNew {
            navigationController?.popViewController(animated: false)
        }
    }
    
    // MARK: - Private
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = createFavoriteButton()
        nameView.text = cat.name + " " + cat.gender.icon
        descriptionView.text = cat.description ?? "У этого котика нет описания"
        descriptionView.textColor = cat.description == nil ? .darkGray : .label
        likesButton.setTitle("👍 " + String(cat.likes), for: .normal)
        dislikesButton.setTitle("👎 " + String(cat.dislikes), for: .normal)
        likesButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        dislikesButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        newCatInfo.isHidden = !isNew
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        catImageView.addGestureRecognizer(recognizer)
        networkService.loadCatPhotosList(by: cat.id) { [weak self] result in
            if case .success(let list) = result,
               let url = list.first {
                DispatchQueue.performOnMain {
                    self?.imageResolver.applyImage(by: url) { image in
                        if let image {
                            self?.catImageView.image = image
                        }
                    }
                }
            }
        }
        
        view.addSubview(newCatInfo)
        view.addSubview(nameView)
        view.addSubview(descriptionView)
        view.addSubview(likesButton)
        view.addSubview(dislikesButton)
        view.addSubview(catImageView)
        
        NSLayoutConstraint.activate([
            newCatInfo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            newCatInfo.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            newCatInfo.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            nameView.topAnchor.constraint(equalTo: newCatInfo.bottomAnchor, constant: 16),
            nameView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameView.trailingAnchor.constraint(equalTo: dislikesButton.leadingAnchor, constant: -16),
            
            likesButton.centerYAnchor.constraint(equalTo: nameView.centerYAnchor),
            likesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dislikesButton.centerYAnchor.constraint(equalTo: likesButton.centerYAnchor),
            dislikesButton.trailingAnchor.constraint(equalTo: likesButton.leadingAnchor, constant: -16),
            
            descriptionView.leadingAnchor.constraint(equalTo: nameView.leadingAnchor),
            descriptionView.topAnchor.constraint(equalTo: nameView.bottomAnchor, constant: 16),
            descriptionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionView.heightAnchor.constraint(equalToConstant: 100),
            
            catImageView.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 16),
            catImageView.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: 16),
            catImageView.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -16),
            catImageView.heightAnchor.constraint(equalTo: catImageView.widthAnchor)
        ])
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - Private
    
    private func createFavoriteButton() -> UIBarButtonItem {
        let settingsImage = UIImage(systemName: "star.fill")
        let button = UIButton(type: .system)
        button.setImage(settingsImage, for: .normal)
        button.addTarget(self, action: #selector(didTapFavButton), for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: button)
        if let view = menuBarItem.customView {
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: 26),
                view.widthAnchor.constraint(equalTo: view.heightAnchor)
            ])
            view.tintColor = cache.contains(catId: cat.id) ? .orange : .gray
        }
        return menuBarItem
    }
    
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    private func didTapImage(_ sender: UITapGestureRecognizer) {
        if sender.view === catImageView {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            present(imagePicker, animated: true)
        }
    }
    
    @objc
    private func didTapFavButton(_ sender: UIButton) {
        if navigationItem.rightBarButtonItem?.customView?.tintColor == .gray {
            cache.add(cat: cat)
            navigationItem.rightBarButtonItem?.customView?.tintColor = .orange
        } else {
            cache.remove(catId: cat.id)
            navigationItem.rightBarButtonItem?.customView?.tintColor = .gray
        }
    }
    
    @objc
    private func didTapLike(_ sender: UIButton) {
        let changes = !sender.isSelected
        switch sender {
        case likesButton:
            networkService.likesRequest(
                identifier: cat.id,
                like: {
                    if changes {
                        likesButton.setTitle("👍 " + String(cat.likes + 1), for: .normal)
                    } else {
                        likesButton.setTitle("👍 " + String(cat.likes), for: .normal)
                    }
                    return changes
                }(),
                dislike: {
                    if changes, dislikesButton.isSelected {
                        dislikesButton.isSelected = false
                        dislikesButton.setTitle("👎 " + String(cat.dislikes), for: .normal)
                        return false
                    }
                    return nil
                }()
            )
        case dislikesButton:
            networkService.likesRequest(
                identifier: cat.id,
                like: {
                    if changes, likesButton.isSelected {
                        likesButton.isSelected = false
                        likesButton.setTitle("👍 " + String(cat.likes), for: .normal)
                        return false
                    }
                    return nil
                }(),
                dislike: {
                    if changes {
                        dislikesButton.setTitle("👎 " + String(cat.dislikes + 1), for: .normal)
                    } else {
                        dislikesButton.setTitle("👎 " + String(cat.dislikes), for: .normal)
                    }
                    return changes
                }()
            )
        default:
            break
        }
        sender.isSelected.toggle()
    }
}

// MARK: - UITextViewDelegate

extension CatViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            networkService.updateDescription(for: cat.id, description: textView.text, completion: nil)
            return false
        }
        return true
    }
}

// MARK: - UIImagePickerControllerDelegate

extension CatViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let newImage = info[.originalImage] as? UIImage,
           let data = newImage.jpegData(compressionQuality: 1) {
            networkService.uploadCatPhoto(
                for: cat.id,
                imageData: data,
                nil
            )
            catImageView.image = newImage
        }
        picker.dismiss(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate

extension CatViewController: UINavigationControllerDelegate {}
