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

  case comics
}

extension Marvel: TargetType {
  var baseURL: URL {
    return URL(string: "https://gateway.marvel.com/v1/public")!
  }

  var path: String {
    switch self {
    case .comics: return "/comics"
    }
  }

  var method: Moya.Method {
    switch self {
    case .comics: return .get
    }
  }

  var sampleData: Data {
    return Data()
  }

  var task: Task {
    let timestamp = "\(Date().timeIntervalSince1970)"
    let hash = (timestamp + Marvel.privateKey + Marvel.publicKey).md5
    let authParams = ["apikey": Marvel.publicKey, "ts": timestamp, "hash": hash]

    switch self {
    case .comics:
      var params: [String: Any] = [
        "format": "comic",
        "formatType": "comic",
        "orderBy": "-onsaleDate",
        "dateDescriptor": "lastWeek",
        "limit": 50
      ]

      params.merge(authParams) { (_, new) in new }

      return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }
  }

  var headers: [String: String]? {
    return ["Content-Type": "application/json"]
  }

  var validationType: ValidationType {
    return .successCodes
  }
}
