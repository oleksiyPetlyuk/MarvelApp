//
//  Marvel.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 07.10.2021.
//

import Foundation
import Moya

enum Marvel {
  static private let privateKey = "ef62a4c37fea721b01b122a97317cbdf56051f43"
  static private let publicKey = "18637a6c8df47e6993e5aece795a7ef5"

  case newlyReleasedComics
  case findComics(title: String)
  case getCharacters(comic: Comic)
}

extension Marvel: TargetType {
  var baseURL: URL {
    // swiftlint:disable:next force_unwrapping
    return URL(string: "https://gateway.marvel.com/v1/public")!
  }

  var path: String {
    switch self {
    case .newlyReleasedComics, .findComics:
      return "/comics"
    case .getCharacters(let comic):
      return "/comics/\(comic.id)/characters"
    }
  }

  var method: Moya.Method {
    switch self {
    case .newlyReleasedComics, .findComics, .getCharacters: return .get
    }
  }

  var sampleData: Data {
    return Data()
  }

  var task: Task {
    let timestamp = "\(Date().timeIntervalSince1970)"
    let hash = (timestamp + Marvel.privateKey + Marvel.publicKey).md5
    let authParams = ["apikey": Marvel.publicKey, "ts": timestamp, "hash": hash]
    let defaultParams: [String: Any] = [
      "format": "comic",
      "formatType": "comic",
      "orderBy": "-onsaleDate",
      "noVariants": true,
      "limit": 100
    ]

    switch self {
    case .newlyReleasedComics:
      var params: [String: Any] = ["dateDescriptor": "thisMonth"]

      params.merge(defaultParams) { _, new in new }
      params.merge(authParams) { _, new in new }

      return .requestParameters(parameters: params, encoding: URLEncoding.default)
    case let .findComics(title):
      var params: [String: Any] = ["titleStartsWith": title]

      params.merge(defaultParams) { _, new in new }
      params.merge(authParams) { _, new in new }

      return .requestParameters(parameters: params, encoding: URLEncoding.default)
    case .getCharacters:
      return .requestParameters(parameters: authParams, encoding: URLEncoding.default)
    }
  }

  var headers: [String: String]? {
    return ["Content-Type": "application/json"]
  }

  var validationType: ValidationType {
    return .successCodes
  }
}
