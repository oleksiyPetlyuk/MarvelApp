//
//  ComicCell.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 07.10.2021.
//

import UIKit
import Kingfisher

class ComicCell: UITableViewCell {
  @objc static let reuseIdentifier = "ComicCell"

  @IBOutlet weak private var imageThumb: UIImageView!
  @IBOutlet weak private var titleLabel: UILabel!
  @IBOutlet weak private var descriptionLabel: UILabel!

  func configureWith(_ comic: Comic) {
    titleLabel.text = comic.title

    descriptionLabel.attributedText = comic.description?.htmlAttributedString(size: 17) ?? NSAttributedString(
      string: "No description available"
    )
    descriptionLabel.textColor = .darkGray

    imageThumb.kf.indicatorType = .activity
    imageThumb.kf.setImage(with: comic.thumbnail.url, options: [.transition(.fade(0.3))])
  }

  func cancelImageDownloadTask() {
    imageThumb.kf.cancelDownloadTask()
  }
}

extension ComicCell {
  // Function wrapper to use it with Objective-C
  @objc func configure(with comic: ComicObjCWrapper) {
    titleLabel.text = comic.title

    descriptionLabel.attributedText = comic.descriptionWrapper?.htmlAttributedString(size: 17) ?? NSAttributedString(
      string: "No description available"
    )
    descriptionLabel.textColor = .darkGray
  }
}
