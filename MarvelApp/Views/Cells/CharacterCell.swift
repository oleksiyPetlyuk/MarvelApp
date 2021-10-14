//
//  CharacterCell.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 14.10.2021.
//

import UIKit
import Kingfisher

class CharacterCell: UICollectionViewCell {
  static let reuseIdentifier = "CharacterCell"

  private let imageThumb: UIImageView = {
    let imageView = UIImageView()

    imageView.clipsToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleToFill

    return imageView
  }()

  private let nameLabel: UILabel = {
    let label = UILabel()

    label.font = .systemFont(ofSize: 22, weight: .semibold)
    label.textAlignment = .natural
    label.numberOfLines = 1
    label.translatesAutoresizingMaskIntoConstraints = false

    return label
  }()

  private let descriptionLabel: UILabel = {
    let label = UILabel()

    label.font = .systemFont(ofSize: 17)
    label.textColor = .darkGray
    label.textAlignment = .natural
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false

    return label
  }()

  private var layoutConstraints: [NSLayoutConstraint] = []

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.addSubview(imageThumb)
    contentView.addSubview(nameLabel)
    contentView.addSubview(descriptionLabel)

    setupLayoutConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupLayoutConstraints() {
    layoutConstraints = [
      contentView.bottomAnchor.constraint(equalTo: imageThumb.bottomAnchor, constant: 8),
      contentView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 16),
      contentView.bottomAnchor.constraint(greaterThanOrEqualTo: descriptionLabel.bottomAnchor, constant: 8),

      imageThumb.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      imageThumb.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      imageThumb.widthAnchor.constraint(equalTo: imageThumb.heightAnchor, multiplier: 3.0 / 4.0),

      nameLabel.leadingAnchor.constraint(equalTo: imageThumb.trailingAnchor, constant: 8),
      nameLabel.heightAnchor.constraint(equalToConstant: 26),
      nameLabel.topAnchor.constraint(equalTo: imageThumb.topAnchor),
      nameLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: 0),

      descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
      descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
    ]

    layoutConstraints.forEach { $0.isActive = true }
  }

  func configureWith(_ character: Character) {
    nameLabel.text = character.name
    descriptionLabel.text = character.description ?? "No description available"
    imageThumb.kf.indicatorType = .activity
    imageThumb.kf.setImage(with: character.thumbnail.url, options: [.transition(.fade(0.3))])
  }
}
