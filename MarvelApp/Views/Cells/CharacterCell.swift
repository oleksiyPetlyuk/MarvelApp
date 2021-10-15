//
//  CharacterCell.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 14.10.2021.
//

import UIKit
import Kingfisher
import SnapKit

class CharacterCell: UICollectionViewCell {
  static let reuseIdentifier = "CharacterCell"

  private let imageThumb: UIImageView = {
    let imageView = UIImageView()

    imageView.clipsToBounds = true
    imageView.contentMode = .scaleToFill

    return imageView
  }()

  private let nameLabel: UILabel = {
    let label = UILabel()

    label.font = .systemFont(ofSize: 22, weight: .semibold)
    label.textAlignment = .natural
    label.numberOfLines = 1

    return label
  }()

  private let descriptionLabel: UILabel = {
    let label = UILabel()

    label.font = .systemFont(ofSize: 17)
    label.textColor = .darkGray
    label.textAlignment = .natural
    label.numberOfLines = 0

    return label
  }()

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
    imageThumb.snp.makeConstraints { make in
      make.bottom.equalToSuperview().offset(-8)
      make.leading.equalToSuperview().offset(16)
      make.top.equalToSuperview().offset(8)
      make.width.equalTo(imageThumb.snp.height).multipliedBy(3.0 / 4.0)
    }

    nameLabel.snp.makeConstraints { make in
      make.trailing.equalToSuperview().offset(-16)
      make.leading.equalTo(imageThumb.snp.trailing).offset(8)
      make.height.equalTo(26)
      make.top.equalTo(imageThumb.snp.top)
      make.bottom.equalTo(descriptionLabel.snp.top)
    }

    descriptionLabel.snp.makeConstraints { make in
      make.leading.trailing.equalTo(nameLabel)
      make.bottom.lessThanOrEqualToSuperview().offset(-8)
    }
  }

  func configureWith(_ character: Character) {
    nameLabel.text = character.name
    descriptionLabel.text = character.description ?? "No description available"
    imageThumb.kf.indicatorType = .activity
    imageThumb.kf.setImage(with: character.thumbnail.url, options: [.transition(.fade(0.3))])
  }
}
