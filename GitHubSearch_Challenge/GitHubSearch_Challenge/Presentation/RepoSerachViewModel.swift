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
    typealias FetchCompletionHandler = (Result<SuccessFetchType, RepoSerachViewModelError>) -> Void

    var isFetching: Bool { get }
    var isNextPageAvailable: Bool { get }

    func search(query: String, completionHandler: @escaping FetchCompletionHandler)
    func nextPage(completionHandler: @escaping FetchCompletionHandler)

    func repoSelected(_ repo: Repo)
}

class DefaultRepoSerachViewModel: RepoSerachViewModel {
    var handleUrlOpen: (_ url: URL) -> Void = { _ in }

    private(set) var isFetching: Bool = false
    var isNextPageAvailable: Bool {
        guard let latestPage = _latestPage else { return false }

        return !latestPage.isLastPage
    }

    private let _useCase: SearchRepoUseCase
    private var _latestPage: RepoSearchPage?
    private var _items: OrderedSet<Item> = []
    private var _latestTask: Cancellable?

    init(useCase: SearchRepoUseCase) {
        self._useCase = useCase
    }

    func search(query: String, completionHandler: @escaping FetchCompletionHandler) {
        _latestTask?.cancel()
        _latestPage = nil
        _items = []

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            completionHandler(.success((_items.elements, isNextPageAvailable)))
            return
        }

        fetch(query: trimmedQuery, page: 1, completionHandler: completionHandler)
    }

    func nextPage(completionHandler: @escaping FetchCompletionHandler) {
        guard let latestPage = _latestPage, !latestPage.isLastPage else {
            completionHandler(.failure(.nextPageUnavailable))
            return
        }

        guard !isFetching else {
            completionHandler(.failure(.fetchingInProgress))
            return
        }

        fetch(query: latestPage.query, page: latestPage.page + 1, completionHandler: completionHandler)
    }

    func repoSelected(_ repo: Repo) {
        guard let url = URL(string: repo.htmlURL) else { return }

        handleUrlOpen(url)
    }

    private func fetch(query: String, page: Int, completionHandler: @escaping FetchCompletionHandler) {
        isFetching = true
        _latestTask = _useCase.execute(requestValue: .init(query: query, page: page)) { [weak self] result in
            guard let strongSelf = self else { return }

            strongSelf._latestTask = nil
            strongSelf.isFetching = false

            switch result {
            case .success(let page):
                strongSelf._latestPage = page
                strongSelf._items.append(contentsOf: page.repos.map({ Item.repo($0) }))
                completionHandler(.success((strongSelf._items.elements, strongSelf.isNextPageAvailable)))
            case .failure(let error):
                // Ignore cancelled error
                if case let GitHubRepositoryError.unknown(error) = error,
                   (error as NSError).code == NSURLErrorCancelled {
                    return
                }

                completionHandler(.failure(.repoError(error)))
            }
        }
    }
}
