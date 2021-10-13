//
//  ComicsViewController.swift
//  MarvelApp
//
//  Created by Oleksiy Petlyuk on 07.10.2021.
//

import UIKit
import Moya

class ComicsViewController: UIViewController {
  let provider = MoyaProvider<Marvel>()

  // MARK: - View State
  private var state: State = .loading {
    didSet {
      switch state {
      case .ready(let items):
        activityIndicatorView.isHidden = true

        if items.isEmpty {
          comicsTable.isHidden = true
          messageView.isHidden = false
          messageLabel.text = "Nothing was found 😩"
        } else {
          messageView.isHidden = true
          comicsTable.isHidden = false
          comicsTable.reloadData()
        }
      case .loading:
        activityIndicatorView.isHidden = false
        comicsTable.isHidden = true
        messageView.isHidden = true
      case .error:
        activityIndicatorView.isHidden = true
        comicsTable.isHidden = true
        messageView.isHidden = false
        messageLabel.text = "Oops! Something went wrong 😩"
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

    setupSearchController()

    getNewlyReleasedComics()
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

  private func getNewlyReleasedComics() {
    state = .loading

    provider.request(.newlyReleasedComics) { [weak self] result in
      guard let self = self else { return }

      self.handle(result: result)
    }
  }

  private func getComicsWith(title: String) {
    state = .loading

    provider.request(.findComics(title: title)) { [weak self] result in
      guard let self = self else { return }

      self.handle(result: result)
    }
  }

  private func handle(result: Result<Response, MoyaError>) {
    switch result {
    case .success(let response):
      do {
        self.state = .ready(try response.map(MarvelResponse<Comic>.self).data.results)
      } catch {
        self.state = .error
      }
    case .failure:
      self.state = .error
    }
  }
}

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

    cell.configureWith(items[indexPath.item])

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

    getComicsWith(title: searchText)
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    getNewlyReleasedComics()
  }
}
