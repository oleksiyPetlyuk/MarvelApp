//
//  MarvelAppTests.swift
//  MarvelAppTests
//
//  Created by Oleksiy Petlyuk on 07.10.2021.
//

import XCTest
@testable import MarvelApp

class ComicsLibraryTests: XCTestCase {
  func test_initSuccess() {
    let dummyReader = DummyDataReader()
    let storage = FileSystemDataWriter()

    XCTAssertNoThrow(try ComicsLibrary(dummyReader, storage: storage))
  }

  func test_initFail() {
    let stubReader = StubDataReader()
    let storage = FileSystemDataWriter()

    let library = try? ComicsLibrary(stubReader, storage: storage)

    XCTAssertNil(library)
  }

  func test_addRemoveItems() throws {
    let fakeReader = FakeDataReader()
    var expectedComicsCount = fakeReader.favoritesComicsCount
    let storage = FileSystemDataWriter()
    let library = try ComicsLibrary(fakeReader, storage: storage)

    XCTAssertEqual(library.items.count, expectedComicsCount)

    library.add([
      Comic(id: 1, title: "Spider-Man", thumbnail: Thumbnail(path: "image", extension: "jpg"), characters: []),
      Comic(id: 2, title: "Hulk", thumbnail: Thumbnail(path: "image", extension: "jpg"), characters: [])
    ])

    expectedComicsCount += 2

    XCTAssertEqual(library.items.count, expectedComicsCount)

    library.remove(whereId: 1)

    expectedComicsCount -= 1

    XCTAssertEqual(library.items.count, expectedComicsCount)

    library.items.forEach { library.remove(whereId: $0.id) }

    XCTAssertEqual(library.items.count, 0)
  }

  func test_restoresFromDisk() throws {
    let dummyReader = DummyDataReader()
    let storage = FileSystemDataWriter()
    let queue = DispatchQueue(label: "ComicsLibraryTests")
    var library = try ComicsLibrary(dummyReader, storage: storage, queue: queue)

    XCTAssertEqual(library.items.count, 0)

    library.add([
      Comic(id: 1, title: "Spider-Man", thumbnail: Thumbnail(path: "image", extension: "jpg"), characters: []),
      Comic(id: 2, title: "Hulk", thumbnail: Thumbnail(path: "image", extension: "jpg"), characters: [])
    ])

    // Issue an empty closure on the queue and wait for it to be executed
    queue.sync {}

    let dataReader = ApiDataReader()
    library = try ComicsLibrary(dataReader, storage: storage)

    XCTAssertEqual(library.items.count, 2)
  }
}
