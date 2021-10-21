//
//  MarvelAppTests.swift
//  MarvelAppTests
//
//  Created by Oleksiy Petlyuk on 07.10.2021.
//

import XCTest
@testable import MarvelApp

class ComicsLibraryTests: XCTestCase {
  func test_InitSuccess() {
    let dummyReader = DummyDataReader()
    let storage = FileSystemDataWriter()

    XCTAssertNoThrow(try ComicsLibrary(dummyReader, storage: storage))
  }

  func test_InitFail() {
    let stubReader = StubDataReader()
    let storage = FileSystemDataWriter()

    let library = try? ComicsLibrary(stubReader, storage: storage)

    XCTAssertNil(library)
  }

  func test_AddRemoveItems() throws {
    let fakeReader = FakeDataReader()
    let storage = FileSystemDataWriter()
    let library = try ComicsLibrary(fakeReader, storage: storage)

    XCTAssertEqual(library.items.count, 10)

    library.add([
      Comic(id: 1, title: "Spider-Man", thumbnail: Thumbnail(path: "image", extension: "jpg"), characters: []),
      Comic(id: 2, title: "Hulk", thumbnail: Thumbnail(path: "image", extension: "jpg"), characters: [])
    ])

    XCTAssertEqual(library.items.count, 12)

    library.remove(whereId: 1)

    XCTAssertEqual(library.items.count, 11)

    library.items.forEach { library.remove(whereId: $0.id) }

    XCTAssertEqual(library.items.count, 0)
  }

  func test_RestoresFromDisk() throws {
    let dummyReader = DummyDataReader()
    let storage = FileSystemDataWriter()
    var library = try ComicsLibrary(dummyReader, storage: storage)

    XCTAssertEqual(library.items.count, 0)

    library.add([
      Comic(id: 1, title: "Spider-Man", thumbnail: Thumbnail(path: "image", extension: "jpg"), characters: []),
      Comic(id: 2, title: "Hulk", thumbnail: Thumbnail(path: "image", extension: "jpg"), characters: [])
    ])

    // sleep to make sure async write task is completed
    sleep(5)

    let dataReader = ApiDataReader()
    library = try ComicsLibrary(dataReader, storage: storage)

    XCTAssertEqual(library.items.count, 2)
  }
}
