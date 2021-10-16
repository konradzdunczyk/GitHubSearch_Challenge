//
//  RepoSerachViewController.swift
//  GitHubSearch_Challenge
//
//  Created by Zduńczyk Konrad on 13/10/2021.
//

import UIKit

enum Section: Hashable {
    case repos
    case fetching
}

enum Item: Hashable {
    case repo(_ repo: Repo)
    case fetching
    case retryFetching

    func hash(into hasher: inout Hasher) {
        switch self {
        case .repo(let item):
            hasher.combine(item.id)
        case .fetching:
            hasher.combine("fetching")
        case .retryFetching:
            hasher.combine("retryFetching")
        }
    }

    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

class RepoSerachViewController: UIViewController {
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    private let _viewModel: RepoSerachViewModel
    private let _tableView: UITableView = {
        let tv = UITableView(frame: CGRect(), style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.allowsMultipleSelection = false
        tv.showsVerticalScrollIndicator = true

        // Removing spaces between sections
        tv.sectionHeaderHeight = 0.0
        tv.sectionFooterHeight = 0.0

        tv.contentInsetAdjustmentBehavior = .never
        // 0.0 height is ignored
        tv.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0,
                                                  width: 0.0,
                                                  height: 0.01))

        return tv
    }()

    private var dataSource: DataSource!

    init(viewModel: RepoSerachViewModel) {
        self._viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    init() {
        fatalError("init() has not been implemented")
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:, bundle:) has not been implemented")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()
        setupViews()
        setupConstraints()

        _viewModel.search(query: "Alamofire", completionHandler: { result in
            switch result {
            case .success(let (items, _)):
                self.apply(items: items)
            case .failure(let error):
                // TODO: Show fullscreen error
                debugPrint(error)
            }
        })
    }

    private func apply(items: [Item]) {
        var snapshot = Snapshot()

        if !items.isEmpty {
            snapshot.appendSections([Section.repos])
            snapshot.appendItems(items, toSection: Section.repos)
        }

        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    private func setupViews() {
        view.backgroundColor = .white

        _tableView.register(UITableViewCell.self, forCellReuseIdentifier: "repo")
        _tableView.register(UITableViewCell.self, forCellReuseIdentifier: "fetching")
        _tableView.register(UITableViewCell.self, forCellReuseIdentifier: "retryFetching")

        _tableView.delegate = self

        view.addSubview(_tableView)
    }

    private func setupConstraints() {
        let c = [
            _tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            _tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            _tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            _tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]

        NSLayoutConstraint.activate(c)
    }

    private func setupDataSource() {
        dataSource = .init(tableView: _tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .repo(let item):
                let cell = tableView.dequeueReusableCell(withIdentifier: "repo", for: indexPath)
                var config = cell.defaultContentConfiguration()
                config.attributedText = {
                    $0.append(NSAttributedString(string: "\(item.ownerName)\\",
                                                 attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]))
                    $0.append(NSAttributedString(string: "\(item.name)",
                                                 attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]))

                    return $0
                }(NSMutableAttributedString())
                config.secondaryText = "License: \(item.licenseName ?? "NONE")"

                cell.contentConfiguration = config

                return cell
            case .fetching:
                let cell = tableView.dequeueReusableCell(withIdentifier: "fetching", for: indexPath)
                var config = cell.defaultContentConfiguration()
                config.text = ">>> FETCHING <<<"
                cell.contentConfiguration = config

                return cell
            case .retryFetching:
                let cell = tableView.dequeueReusableCell(withIdentifier: "retryFetching", for: indexPath)
                var config = cell.defaultContentConfiguration()
                config.text = ">>> RETRY FETCHING <<<"
                cell.contentConfiguration = config

                return cell
            }
        })
    }
}

extension RepoSerachViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        guard case let .repo(repo) = dataSource.itemIdentifier(for: indexPath) else { return }
        _viewModel.repoSelected(repo)
    }
}
