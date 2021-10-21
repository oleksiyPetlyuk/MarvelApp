//
//  DataWriter.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 20.10.2021.
//

import Foundation

protocol DataWriter {
  // swiftlint:disable:next identifier_name
  func write(_ data: Data, to: URL?) throws
}

class FileSystemDataWriter: DataWriter {
  enum FileSystemDataWriterError: Error {
    case noURLProvided
  }

  func write(_ data: Data, to url: URL?) throws {
    guard let url = url else {
      throw FileSystemDataWriterError.noURLProvided
    }

    try data.write(to: url, options: .atomic)
  }
}
