//
//  ComicViewController.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 13.10.2021.
//

import UIKit
import SnapKit

class ComicViewController: UIViewController {
  var library: ComicsLibrary!

  // MARK: - View State
  private var state: State = .loading {
    didSet {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }

        switch self.state {
        case .ready(let items):
          self.activityIndicator.stopAnimating()

          if items.isEmpty {
            self.messageLabel.text = "No characters were found 🤷‍♂️"
            self.messageLabel.isHidden = false
          } else {
            self.messageLabel.isHidden = true
            self.collectionView.reloadData()
          }
        case .loading:
          self.messageLabel.isHidden = true
          self.activityIndicator.startAnimating()
        case .error:
          self.activityIndicator.stopAnimating()
          self.messageLabel.text = "Oops! Something went wrong 😩"
          self.messageLabel.isHidden = false
        }
      }
    }
  }

  private let collectionView: UICollectionView = {
    let layout = StretchyHeaderLayout()

    layout.sectionInset = .init(top: 16, left: 0, bottom: 0, right: 0)
    layout.minimumLineSpacing = 0

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    collectionView.register(CharacterCell.self, forCellWithReuseIdentifier: CharacterCell.reuseIdentifier)
    collectionView.register(
      ComicHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: ComicHeaderView.reuseIdentifier
    )

    return collectionView
  }()

  private let activityIndicator: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView(style: .large)
    activityIndicator.color = .systemRed

    return activityIndicator
  }()

  private let messageLabel: UILabel = {
    let label = UILabel()

    label.font = .systemFont(ofSize: 22)
    label.textAlignment = .center
    label.numberOfLines = 0

    return label
  }()

  private var comic: Comic?

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let comic = comic else { fatalError("Please provide a valid Comic object") }

    navigationItem.largeTitleDisplayMode = .never
    navigationItem.title = comic.title

    state = .loading

    do {
      library = try ComicsLibrary(ApiDataReader(), storage: FileSystemDataWriter())
    } catch {
      fatalError(error.localizedDescription)
    }

    setupCollectionView()
    setupActivityIndicator()
    setupMessageLabel()

    async {
      await getCharacters(of: comic)
    }
  }

  private func setupCollectionView() {
    view.addSubview(collectionView)

    collectionView.dataSource = self
    collectionView.delegate = self

    collectionView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }

  private func setupActivityIndicator() {
    view.addSubview(activityIndicator)

    let centerY = ComicViewController.sectionHeaderHeight / 2

    activityIndicator.snp.makeConstraints { make in
      make.centerX.equalTo(collectionView)
      make.centerY.equalTo(collectionView).offset(centerY)
    }
  }

  private func setupMessageLabel() {
    view.addSubview(messageLabel)

    let centerY = ComicViewController.sectionHeaderHeight / 2

    messageLabel.snp.makeConstraints { make in
      make.centerX.equalTo(collectionView)
      make.centerY.equalTo(collectionView).offset(centerY)
    }
  }

  private func getCharacters(of comic: Comic) async {
    state = .loading

    do {
      let characters = try await library.getCharacters(of: comic)
      state = .ready(characters)
    } catch {
      state = .error
    }
  }
}

// MARK: - FlowLayout Delegate
extension ComicViewController: UICollectionViewDelegateFlowLayout {
  private static let sectionHeaderHeight: CGFloat = 340.0

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return .init(width: view.frame.width, height: ComicViewController.sectionHeaderHeight)
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
