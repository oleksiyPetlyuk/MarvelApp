//
//  Comic.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 07.10.2021.
//

import Foundation

struct Comic: Codable {
  let id: Int
  let title: String
  let description: String?
  let thumbnail: Thumbnail
  let characters: CharactersInfo
  private let dates: [Date]
}

extension Comic {
  struct Thumbnail: Codable {
    let path: String
    let `extension`: String

    var url: URL {
      // swiftlint:disable:next force_unwrapping
      return URL(string: path + "." + `extension`)!
    }
  }
}

extension Comic {
  struct Date: Codable {
    let type: String
    let date: String
  }
}

extension Comic {
  struct CharactersInfo: Codable {
    let available: Int
    let items: [Character]
  }

  struct Character: Codable {
    let resourceURI: URL
    let name: String
  }
}
