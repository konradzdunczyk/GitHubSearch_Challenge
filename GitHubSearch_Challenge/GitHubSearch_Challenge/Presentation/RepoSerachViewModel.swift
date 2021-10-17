//
//  RepoSerachViewModel.swift
//  GitHubSearch_Challenge
//
//  Created by Zduńczyk Konrad on 16/10/2021.
//

import Foundation
import OrderedCollections

protocol RepoSerachViewModel: AnyObject {
    typealias SuccessFetchType = (items: [Item], isNextPageAvailable: Bool)
    typealias FetchCompletionHandler = (Result<SuccessFetchType, Error>) -> Void

    var items: [Item] { get }
    var isFetching: Bool { get }
    var isNextPageAvailable: Bool { get }

    func search(query: String, completionHandler: @escaping FetchCompletionHandler)
    func nextPage(completionHandler: @escaping FetchCompletionHandler)

    func repoSelected(_ repo: Repo)
}

class DefaultRepoSerachViewModel: RepoSerachViewModel {
    var handleUrlOpen: (_ url: URL) -> Void = { _ in }

    var items: [Item] { _items.elements }
    private(set) var isFetching: Bool = false
    var isNextPageAvailable: Bool {
        guard let latestPage = _latestPage else { return false }

        return !latestPage.isLastPage
    }

    private let _useCase: SearchRepoUseCase
    private var _latestPage: RepoSearchPage?
    private var _items: OrderedSet<Item> = []

    init(useCase: SearchRepoUseCase) {
        self._useCase = useCase
    }

    func search(query: String, completionHandler: @escaping FetchCompletionHandler) {
        // TODO: Add task cancelation
        guard !isFetching else { return }

        _latestPage = nil
        _items = []

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            completionHandler(.success((items, isNextPageAvailable)))
            return
        }

        isFetching = true
        fetch(query: trimmedQuery, page: 1, completionHandler: completionHandler)
    }

    func nextPage(completionHandler: @escaping FetchCompletionHandler) {
        guard let latestPage = _latestPage, !latestPage.isLastPage && !isFetching else { return }

        fetch(query: latestPage.query, page: latestPage.page + 1, completionHandler: completionHandler)
    }

    func repoSelected(_ repo: Repo) {
        guard let url = URL(string: repo.htmlURL) else { return }

        handleUrlOpen(url)
    }

    private func fetch(query: String, page: Int, completionHandler: @escaping FetchCompletionHandler) {
        _useCase.execute(requestValue: .init(query: query, page: page)) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let page):
                strongSelf._latestPage = page
                strongSelf._items.append(contentsOf: page.repos.map({ Item.repo($0) }))
                completionHandler(.success((strongSelf.items, strongSelf.isNextPageAvailable)))
            case .failure(let error):
                completionHandler(.failure(error))
            }

            strongSelf.isFetching = false
        }
    }
}
