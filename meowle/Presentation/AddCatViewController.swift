//
//  AddCatViewController.swift
//  meowle
//
//  Created by a.gorshchak on 03.02.2024.
//

import UIKit

final class AddCatViewController: UIViewController {
    
    // UI
    private let nameField = {
        let textField = UITextField()
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.black.cgColor
        textField.placeholder = "Введите имя котика"
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    private lazy var genderPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    private lazy var descriptionView: UITextView = {
        let view = UITextView()
        view.delegate = self
        view.text = "Введите описание котика"
        view.textColor = .lightGray
        view.layer.cornerRadius = 5
        view.returnKeyType = .done
        view.backgroundColor = .lightGray.withAlphaComponent(0.15)
        view.font = .systemFont(ofSize: 17)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "photo")
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 10
        view.isUserInteractionEnabled = true
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var doneButton = {
        let button = UIButton(configuration: UIButton.Configuration.bordered())
        button.setTitle("Добавить", for: .normal)
        button.accessibilityIdentifier = "superButton"
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    

    private var catImage: UIImage? {
        didSet {
            imageView.image = catImage
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
            title: "Добавить",
            image: UIImage(systemName: "plus.circle"),
            tag: 2
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = "addAnewCatScreenViewController"
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameField.text = nil
        descriptionView.text = nil
        genderPicker.selectRow(.zero, inComponent: .zero, animated: false)
        imageView.image = UIImage(systemName: "photo")
        
        if descriptionView.text?.isEmpty != false {
            descriptionView.text = "Введите описание котика"
            descriptionView.textColor = .lightGray
        }
    }
    
    // MARK: - Private
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        imageView.addGestureRecognizer(recognizer)
        
        let stackView = UIStackView(arrangedSubviews: [
            nameField,
            genderPicker,
            descriptionView,
            imageView,
            doneButton
        ])
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameField.heightAnchor.constraint(equalToConstant: 25),
            genderPicker.heightAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.5),
            descriptionView.heightAnchor.constraint(equalToConstant: 100)
        ])
        hideKeyboardWhenTappedAround()
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
        if sender.view === imageView {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            present(imagePicker, animated: true)
        }
    }
    
    @objc
    private func didTapButton(_ sender: UIButton) {
        if sender === doneButton {
            if let name = nameField.text {
                networkService.uploadNewCat(
                    name: name,
                    gender: Gender.allCases[genderPicker.selectedRow(inComponent: 0)].rawValue
                ) { [weak self] result in
                    guard let self = self else {
                        DispatchQueue.performOnMain {
                            let alert = UIAlertController(
                                title: "Ошибка",
                                message: "Котика добавить не удалось",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "Ок", style: .default))
                            self?.navigationController?.present(alert, animated: true)
                        }
                        return
                    }
                    switch result {
                    case .success(var cat):
                        DispatchQueue.performOnMain {
                            let semaphore = DispatchSemaphore(value: 0)
                            if self.descriptionView.textColor != .lightGray,
                               let descriptionText = self.descriptionView.text,
                               !descriptionText.isEmpty {
                                self.networkService.updateDescription(for: cat.id, description: descriptionText) {
                                    cat = Cat(
                                        id: cat.id,
                                        name: cat.name,
                                        description: descriptionText,
                                        gender: cat.gender,
                                        likes: cat.likes,
                                        dislikes: cat.dislikes
                                    )
                                    semaphore.signal()
                                }
                            } else {
                                semaphore.signal()
                            }
                            semaphore.wait()
                        }
                        if let data = self.catImage?.jpegData(compressionQuality: 1) {
                            self.networkService.uploadCatPhoto(
                                for: cat.id,
                                imageData: data
                            ) {
                                DispatchQueue.performOnMain {
                                    let vc = CatViewController(
                                        networkService: self.networkService,
                                        imageResolver: self.imageResolversFactory.buildImageResolver(),
                                        cat: cat,
                                        isNew: true
                                    )
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        } else {
                            DispatchQueue.performOnMain {
                                let vc = CatViewController(
                                    networkService: self.networkService,
                                    imageResolver: self.imageResolversFactory.buildImageResolver(),
                                    cat: cat,
                                    isNew: true
                                )
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.performOnMain {
                            let alert = UIAlertController(
                                title: "Ошибка",
                                message: error.localizedDescription,
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "Ок", style: .default))
                            self.navigationController?.present(alert, animated: true)
                        }
                        print(error)
                    }
                }
            }
        }
    }
}

// MARK: - UIPickerViewDataSource

extension AddCatViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        return Gender.allCases.count
    }
}

// MARK: - UIPickerViewDelegate

extension AddCatViewController: UIPickerViewDelegate {
    
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        return Gender.allCases[row].rawValue
    }
}

// MARK: - UITextViewDelegate

extension AddCatViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

// MARK: - UIImagePickerControllerDelegate

extension AddCatViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let newImage = info[.originalImage] as? UIImage {
            catImage = newImage
        }
        picker.dismiss(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate

extension AddCatViewController: UINavigationControllerDelegate {}
