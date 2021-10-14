//
//  Thumbnail.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 14.10.2021.
//

import Foundation

struct Thumbnail: Codable {
  let path: String
  let `extension`: String

  var url: URL {
    // swiftlint:disable:next force_unwrapping
    return URL(string: path + "." + `extension`)!
  }
}
