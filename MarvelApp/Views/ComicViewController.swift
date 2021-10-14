//
//  ComicViewController.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 13.10.2021.
//

import UIKit
import Moya

class ComicViewController: UIViewController {
  let provider = MoyaProvider<Marvel>()

  // MARK: - View State
  private var state: State = .loading {
    didSet {
      switch state {
      case .ready(let items):
        print(items.count)
        collectionView.reloadData()
      case .loading:
        print("loading")
      case .error:
        print("Error")
      }
    }
  }

  private let collectionView: UICollectionView = {
    let layout = StretchyHeaderLayout()

    layout.sectionInset = .init(top: 16, left: 0, bottom: 0, right: 0)
    layout.minimumLineSpacing = 0

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    collectionView.translatesAutoresizingMaskIntoConstraints = false

    collectionView.register(CharacterCell.self, forCellWithReuseIdentifier: CharacterCell.reuseIdentifier)
    collectionView.register(
      ComicHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: ComicHeaderView.reuseIdentifier
    )

    return collectionView
  }()

  private var comic: Comic?

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let comic = comic else { fatalError("Please provide a valid Comic object") }

    navigationItem.largeTitleDisplayMode = .never
    navigationItem.title = comic.title

    state = .loading

    setupCollectionView()

    getCharacters(of: comic)
  }

  private func setupCollectionView() {
    view.addSubview(collectionView)

    collectionView.dataSource = self
    collectionView.delegate = self

    collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
  }

  private func getCharacters(of comic: Comic) {
    state = .loading

    provider.request(.getCharacters(comic: comic)) { [weak self] result in
      guard let self = self else { return }

      switch result {
      case .success(let response):
        do {
          self.state = .ready(try response.map(MarvelResponse<Character>.self).data.results)
        } catch {
          self.state = .error
        }
      case .failure:
        self.state = .error
      }
    }
  }
}

// MARK: - FlowLayout Delegate
extension ComicViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return .init(width: view.frame.width, height: 340)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return .init(width: view.frame.width, height: 128)
  }
}

// MARK: - CollectionView Data Source
extension ComicViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard case .ready(let items) = state else { return 0 }

    return items.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: CharacterCell.reuseIdentifier,
      for: indexPath) as? CharacterCell ?? CharacterCell()

    guard case .ready(let items) = state else { return cell }

    cell.configureWith(items[indexPath.item])

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let headerView = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: ComicHeaderView.reuseIdentifier,
      for: indexPath) as? ComicHeaderView ?? ComicHeaderView()

    // swiftlint:disable:next force_unwrapping
    headerView.configureWith(comic!)

    return headerView
  }
}

// MARK: - Helpers
extension ComicViewController {
  enum State {
    case loading
    case ready([Character])
    case error
  }

  static func instantiate(with comic: Comic) -> ComicViewController {
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)

    // swiftlint:disable:next line_length
    guard let viewController = storyBoard.instantiateViewController(withIdentifier: "ComicViewController") as? ComicViewController else {
      fatalError("Failed to get ComicViewController from Storyboard")
    }

    viewController.comic = comic

    return viewController
  }
}
