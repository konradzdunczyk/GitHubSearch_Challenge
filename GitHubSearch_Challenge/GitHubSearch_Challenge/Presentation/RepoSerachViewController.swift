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
    private let _searchBar: UISearchBar = {
        $0.translatesAutoresizingMaskIntoConstraints = false

        return $0
    }(UISearchBar())
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
    private let _snapshotQueue = DispatchQueue(label: "pl.kz.snapshotQueue", qos: .background)

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
    }

    private func apply(items: [Item], isNextPageAvailable: Bool) {
        var snapshot = Snapshot()

        if !items.isEmpty {
            snapshot.appendSections([Section.repos])
            snapshot.appendItems(items, toSection: Section.repos)
        }

        if isNextPageAvailable {
            snapshot.setFetchingItem()
        }

        applySnapshot(snapshot, animated: true)
    }

    private func applySnapshot(_ snapshot: Snapshot, animated: Bool) {
        _snapshotQueue.async {
            self.dataSource.apply(snapshot, animatingDifferences: animated, completion: nil)
        }
    }

    private func fetchNextPage() {
        guard _viewModel.isNextPageAvailable else { return }

        var snapshot = dataSource.snapshot()
        if !snapshot.hasFetchingItem {
            snapshot.setFetchingItem()
            applySnapshot(snapshot, animated: false)
        }

        _viewModel.nextPage { result in
            switch result {
            case .success(let (items, isNextPageAvailable)):
                self.apply(items: items, isNextPageAvailable: isNextPageAvailable)
            case .failure(let error):
                debugPrint(error)

                var snapshot = self.dataSource.snapshot()
                if !snapshot.hasRetryFetchingItem {
                    snapshot.setRetryFetchingItem()
                    self.applySnapshot(snapshot, animated: false)
                }
            }
        }
    }

    private func setupViews() {
        view.backgroundColor = .white

        _tableView.register(UITableViewCell.self, forCellReuseIdentifier: "repo")
        _tableView.register(UITableViewCell.self, forCellReuseIdentifier: "fetching")
        _tableView.register(UITableViewCell.self, forCellReuseIdentifier: "retryFetching")

        _searchBar.delegate = self
        _tableView.delegate = self
        _tableView.prefetchDataSource = self

        view.addSubview(_searchBar)
        view.addSubview(_tableView)
    }

    private func setupConstraints() {
        let c = [
            _searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            _searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            _searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            _tableView.topAnchor.constraint(equalTo: _searchBar.bottomAnchor),
            _tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
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
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        switch item {
        case .repo, .retryFetching:
            return true
        case .fetching:
            return false
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .repo(let repo):
            _viewModel.repoSelected(repo)
        case .fetching:
            break
        case .retryFetching:
            fetchNextPage()
        }
    }
}

extension RepoSerachViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let fetchingSection = dataSource.snapshot().indexOfSection(.fetching),
                !_viewModel.isFetching
                && !dataSource.snapshot().hasRetryFetchingItem
                && indexPaths.contains(.init(row: 0, section: fetchingSection)) else { return }

        fetchNextPage()
    }
}

extension RepoSerachViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        _viewModel.search(query: searchBar.text ?? "") { result in
            switch result {
            case .success(let (items, isNextPageAvailable)):
                self.apply(items: items, isNextPageAvailable: isNextPageAvailable)
            case .failure(let error):
                debugPrint(error)

                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error",
                                                  message: error.localizedDescription,
                                                  preferredStyle: .alert)
                    alert.addAction(.init(title: "OK", style: .default, handler: { _ in searchBar.becomeFirstResponder() }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

private extension RepoSerachViewController.Snapshot {
    var hasFetchingItem: Bool {
        itemIdentifiers(inSection: .fetching).contains(.fetching)
    }

    var hasRetryFetchingItem: Bool {
        itemIdentifiers(inSection: .fetching).contains(.retryFetching)
    }

    mutating func setFetchingItem() {
        setFetchingSection(with: .fetching)
    }

    mutating func setRetryFetchingItem() {
        setFetchingSection(with: .retryFetching)
    }

    private mutating func setFetchingSection(with item: Item) {
        if !sectionIdentifiers.contains(.fetching) {
            appendSections([.fetching])
        }

        let fetchingSectionItems = itemIdentifiers(inSection: .fetching)
        if !fetchingSectionItems.contains(item) {
            deleteItems(fetchingSectionItems)
            appendItems([item], toSection: .fetching)
        }
    }
}
