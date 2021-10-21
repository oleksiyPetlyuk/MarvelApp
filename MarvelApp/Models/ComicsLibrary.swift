//
//  ComicsLibrary.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 20.10.2021.
//

import Foundation

class ComicsLibrary {
  static let storageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("Comics")
    .appendingPathExtension("json")

  private let dataProvider: DataReader

  private let dataStorage: DataWriter

  private(set) var items: [Comic] {
    didSet {
      save()
    }
  }

  init(_ dataProvider: DataReader, storage: DataWriter) throws {
    self.dataProvider = dataProvider
    self.dataStorage = storage
    self.items = try dataProvider.getFavoritesComics()
  }

  func getNewlyReleasedComics() async throws -> [Comic] {
    return try await dataProvider.getNewlyReleasedComics()
  }

  func findComics(startsWith title: String) async throws -> [Comic] {
    return try await dataProvider.findComics(startsWith: title)
  }

  func getCharacters(of comic: Comic) async throws -> [Character] {
    return try await dataProvider.getCharacters(of: comic)
  }

  func add(_ newItems: [Comic]) {
    items.append(contentsOf: newItems)
  }

  func remove(whereId id: Int) {
    items.removeAll { $0.id == id }
  }
}

// MARK: - private
private extension ComicsLibrary {
  func save() {
    DispatchQueue.global().async { [weak self] in
      guard let self = self else { return }

      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted

      let data = try? encoder.encode(self.items)

      guard let data = data else { return }

      try? self.dataStorage.write(data, to: Self.storageURL)
    }
  }
}
