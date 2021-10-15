//
//  HeaderView.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 13.10.2021.
//

import UIKit
import Kingfisher
import SnapKit

class ComicHeaderView: UICollectionReusableView {
  static let reuseIdentifier = "ComicHeaderView"

  let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill

    return imageView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(imageView)

    imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureWith(_ comic: Comic) {
    imageView.kf.setImage(with: comic.thumbnail.url, options: [.transition(.fade(0.3))])
  }
}
