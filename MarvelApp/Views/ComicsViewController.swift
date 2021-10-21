//
//  ComicsViewController.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 07.10.2021.
//

import UIKit

class ComicsViewController: UIViewController {
  var library: ComicsLibrary!

  // MARK: - View State
  private var state: State = .loading {
    didSet {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }

        switch self.state {
        case .ready(let items):
          self.activityIndicatorView.isHidden = true

          if items.isEmpty {
            self.comicsTable.isHidden = true
            self.messageView.isHidden = false
            self.messageLabel.text = "Nothing was found 😩"
          } else {
            self.messageView.isHidden = true
            self.comicsTable.isHidden = false
            self.comicsTable.reloadData()
          }
        case .loading:
          self.activityIndicatorView.isHidden = false
          self.comicsTable.isHidden = true
          self.messageView.isHidden = true
        case .error:
          self.activityIndicatorView.isHidden = true
          self.comicsTable.isHidden = true
          self.messageView.isHidden = false
          self.messageLabel.text = "Oops! Something went wrong 😩"
        }
      }
    }
  }

  // MARK: - Outlets
  @IBOutlet weak private var comicsTable: UITableView!
  @IBOutlet weak private var activityIndicatorView: UIView!
  @IBOutlet weak private var messageView: UIView!
  @IBOutlet weak private var messageLabel: UILabel!

  let searchController = UISearchController(searchResultsController: nil)

  override func viewDidLoad() {
    super.viewDidLoad()

    state = .loading

    do {
      library = try ComicsLibrary(ApiDataReader(), storage: FileSystemDataWriter())
    } catch {
      fatalError(error.localizedDescription)
    }

    setupSearchController()

    async {
      await getNewlyReleasedComics()
    }
  }

  private func setupSearchController() {
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search Comics"
    searchController.searchBar.searchTextField.backgroundColor = .white
    searchController.searchBar.tintColor = .white
    searchController.searchBar.delegate = self

    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    definesPresentationContext = true
  }

  private func getNewlyReleasedComics() async {
    state = .loading

    do {
      let comics = try await library.getNewlyReleasedComics()
      state = .ready(comics)
    } catch {
      state = .error
    }
  }

  private func getComicsWith(title: String) async {
    state = .loading

    do {
      let comics = try await library.findComics(startsWith: title)
      state = .ready(comics)
    } catch {
      state = .error
    }
  }
}

// MARK: - Helpers
extension ComicsViewController {
  enum State {
    case loading
    case ready([Comic])
    case error
  }
}

// MARK: - UITableView Delegate & Data Source
extension ComicsViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: ComicCell.reuseIdentifier,
      for: indexPath) as? ComicCell ?? ComicCell()

    guard case .ready(let items) = state else { return cell }

    cell.configureWith(items[indexPath.row])

    return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard case .ready(let items) = state else { return 0 }

    return items.count
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)

    guard case .ready(let items) = state else { return }

    let comicVC = ComicViewController.instantiate(with: items[indexPath.row])

    navigationController?.pushViewController(comicVC, animated: true)
  }

  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let cell = cell as? ComicCell else { return }

    cell.cancelImageDownloadTask()
  }
}

// MARK: - UISearchBar Delegate
extension ComicsViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let text = searchBar.text else { return }

    let searchText = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

    async {
      await getComicsWith(title: searchText)
    }
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    async {
      await getNewlyReleasedComics()
    }
  }
}
