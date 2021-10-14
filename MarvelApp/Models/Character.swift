//
//  Character.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 14.10.2021.
//

import Foundation

struct Character: Codable {
  let id: Int
  let name: String
  let description: String?
  let thumbnail: Thumbnail
}
