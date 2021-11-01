//
//  DatabaseReader.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 20.10.2021.
//

import Foundation
import Moya

protocol DataReader {
  func getNewlyReleasedComics() async throws -> [Comic]

  func findComics(startsWith title: String) async throws -> [Comic]

  func getCharacters(of comic: Comic) async throws -> [Character]

  func getFavoritesComics() throws -> [Comic]
}

class ApiDataReader: DataReader {
  func getFavoritesComics() throws -> [Comic] {
    let deta = try JSONDecoder().decode([Comic].self, from: .init(contentsOf: ComicsLibrary.storageURL))
    return deta
  }

  let provider = MoyaProvider<Marvel>()

  func getNewlyReleasedComics() async throws -> [Comic] {
    try await withCheckedThrowingContinuation { continuation in
      provider.request(.newlyReleasedComics) { result in
        switch result {
        case .success(let response):
          do {
            let comics = try response.map(MarvelResponse<Comic>.self).data.results

            continuation.resume(returning: comics)
          } catch {
            continuation.resume(throwing: error)
          }
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  func findComics(startsWith title: String) async throws -> [Comic] {
    try await withCheckedThrowingContinuation { continuation in
      provider.request(.findComics(title: title)) { result in
        switch result {
        case .success(let response):
          do {
            let comics = try response.map(MarvelResponse<Comic>.self).data.results

            continuation.resume(returning: comics)
          } catch {
            continuation.resume(throwing: error)
          }
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  func getCharacters(of comic: Comic) async throws -> [Character] {
    try await withCheckedThrowingContinuation { continuation in
      provider.request(.getCharacters(comic: comic)) { result in
        switch result {
        case .success(let response):
          do {
            let characters = try response.map(MarvelResponse<Character>.self).data.results

            continuation.resume(returning: characters)
          } catch {
            continuation.resume(throwing: error)
          }
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}

class DummyDataReader: DataReader {
  func getFavoritesComics() throws -> [Comic] {
    return []
  }

  func getNewlyReleasedComics() async throws -> [Comic] {
    return []
  }

  func findComics(startsWith title: String) async throws -> [Comic] {
    return []
  }

  func getCharacters(of comic: Comic) async throws -> [Character] {
    return []
  }
}

// swiftlint:disable force_unwrapping force_try
class FakeDataReader: DataReader {
  var favoritesComicsCount: Int {
    do {
      return try getFavoritesComics().count
    } catch {
      fatalError(error.localizedDescription)
    }
  }

  func getFavoritesComics() throws -> [Comic] {
    let filePath = Bundle.main.path(forResource: "comics_samples", ofType: "json")
    let data = FileManager.default.contents(atPath: filePath!)
    let decoder = JSONDecoder()
    let comics = try! decoder.decode(MarvelResponse<Comic>.self, from: data!)

    return comics.data.results
  }

  func getNewlyReleasedComics() async throws -> [Comic] {
    return []
  }

  func findComics(startsWith title: String) async throws -> [Comic] {
    return []
  }

  func getCharacters(of comic: Comic) async throws -> [Character] {
    return []
  }
}
// swiftlint:enable force_unwrapping force_try

class StubDataReader: DataReader {
  enum StubDatabaseReaderError: Error {
    case generalError
  }

  func getFavoritesComics() throws -> [Comic] {
    throw StubDatabaseReaderError.generalError
  }

  func getNewlyReleasedComics() async throws -> [Comic] {
    throw StubDatabaseReaderError.generalError
  }

  func findComics(startsWith title: String) async throws -> [Comic] {
    throw StubDatabaseReaderError.generalError
  }

  func getCharacters(of comic: Comic) async throws -> [Character] {
    throw StubDatabaseReaderError.generalError
  }
}
