//
//  ComicCell.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 07.10.2021.
//

import UIKit
import Kingfisher

class ComicCell: UITableViewCell {
  public static let reuseIdentifier = "ComicCell"

  @IBOutlet weak private var imageThumb: UIImageView!
  @IBOutlet weak private var titleLabel: UILabel!
  @IBOutlet weak private var descriptionLabel: UILabel!

  public func configureWith(_ comic: Comic) {
    titleLabel.text = comic.title
    descriptionLabel.text = comic.description ?? "No description available"

    imageThumb.kf.setImage(with: comic.thumbnail.url, options: [.transition(.fade(0.3))])
  }
}
