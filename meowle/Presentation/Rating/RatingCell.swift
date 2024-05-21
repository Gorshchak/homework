//
//  RatingCell.swift
//  meowle
//
//  Created by a.gorshchak on 04.02.2024.
//

import UIKit

final class RatingCell: UITableViewCell {
    
    // Dependencies
    var imageResolver: ImageResolver?
    
    // UI
    private let numberView: UILabel = {
        let view = UILabel()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let catImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "camera.fill")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let nameView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let ratingImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let ratingCounterView: UILabel = {
        let view = UILabel()
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    func configure(
        number: Int,
        imageUrl: URL?,
        name: String,
        isPositive: Bool,
        ratingCount: Int
    ) {
        if let url = imageUrl {
            imageResolver?.applyImage(by: url) { [weak catImageView] image in
                if let image {
                    catImageView?.image = image
                    catImageView?.contentMode = .scaleToFill
                } else {
                    catImageView?.image = UIImage(systemName: "camera.fill")
                    catImageView?.contentMode = .scaleAspectFit
                }
            }
        }
        numberView.text = "\(number)."
        nameView.text = name
        ratingImageView.image = {
            if isPositive {
                return UIImage(systemName: "hand.thumbsup")
            } else {
                return UIImage(systemName: "hand.thumbsdown")
            }
        }()
        let tintColor: () -> UIColor = { isPositive ? .systemGreen : .systemRed }
        ratingImageView.tintColor = tintColor()
        ratingCounterView.text = String(ratingCount)
        ratingCounterView.textColor = tintColor()
    }
    
    // MARK: - Private
    
    private func setupUI() {
        [numberView,
         catImageView,
         nameView,
         ratingImageView,
         ratingCounterView].forEach(contentView.addSubview)
        
        NSLayoutConstraint.activate([
            numberView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            numberView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            numberView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            numberView.widthAnchor.constraint(equalToConstant: 30),
            
            catImageView.heightAnchor.constraint(equalToConstant: 40),
            catImageView.widthAnchor.constraint(equalTo: catImageView.heightAnchor),
            catImageView.leadingAnchor.constraint(equalTo: numberView.trailingAnchor, constant: 16),
            catImageView.centerYAnchor.constraint(equalTo: numberView.centerYAnchor),
            
            nameView.leadingAnchor.constraint(equalTo: catImageView.trailingAnchor, constant: 16),
            nameView.centerYAnchor.constraint(equalTo: numberView.centerYAnchor),
            nameView.trailingAnchor.constraint(equalTo: ratingImageView.leadingAnchor, constant: -16),
            
            ratingImageView.centerYAnchor.constraint(equalTo: nameView.centerYAnchor),
            ratingImageView.heightAnchor.constraint(equalTo: nameView.heightAnchor),
            ratingImageView.widthAnchor.constraint(equalTo: ratingImageView.heightAnchor),
            ratingImageView.trailingAnchor.constraint(equalTo: ratingCounterView.leadingAnchor, constant: -8),
            
            ratingCounterView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ratingCounterView.widthAnchor.constraint(equalToConstant: 25),
            ratingCounterView.centerYAnchor.constraint(equalTo: ratingImageView.centerYAnchor)
        ])
    }
}
