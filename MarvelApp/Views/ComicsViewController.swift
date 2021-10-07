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
      case .ready:
        activityIndicatorView.isHidden = true
        comicsTable.isHidden = false
        comicsTable.reloadData()
      case .loading:
        activityIndicatorView.isHidden = false
        comicsTable.isHidden = true
      case .error:
        activityIndicatorView.isHidden = true
        comicsTable.isHidden = true
      }
    }
  }

  // MARK: - Outlets
  @IBOutlet weak private var comicsTable: UITableView!
  @IBOutlet weak private var activityIndicatorView: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()

    state = .loading

    getData()
  }

  private func getData() {
    provider.request(.comics) { [weak self] result in
      guard let self = self else { return }

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
}
