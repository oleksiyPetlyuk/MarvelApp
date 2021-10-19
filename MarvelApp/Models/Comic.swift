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

// Class wrapper to use it in Objective-C
@objc(Comic)
class ComicObjCWrapper: NSObject, Codable {
  @objc let id: Int
  @objc let title: String
  @objc let descriptionWrapper: String?
}
