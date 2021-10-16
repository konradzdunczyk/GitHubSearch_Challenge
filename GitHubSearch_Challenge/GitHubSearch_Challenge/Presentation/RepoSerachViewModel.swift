//
//  RepoSerachViewModel.swift
//  GitHubSearch_Challenge
//
//  Created by Zduńczyk Konrad on 16/10/2021.
//

import Foundation

protocol RepoSerachViewModel: AnyObject {
    typealias SuccessFetchType = (items: [Item], isNextPageAvailable: Bool)
    typealias FetchCompletionHandler = (Result<SuccessFetchType, Error>) -> Void

    var _items: [Item] { get }
    var isNextPageAvailable: Bool { get }

    func search(query: String, completionHandler: @escaping FetchCompletionHandler)
    func nextPage(completionHandler: @escaping FetchCompletionHandler)

    func repoSelected(_ repo: Repo)
}

class DefaultRepoSerachViewModel: RepoSerachViewModel {
    var handleUrlOpen: (_ url: URL) -> Void = { _ in }

    private(set) var _items: [Item] = []
    var isNextPageAvailable: Bool {
        guard let latestPage = _latestPage else { return false }

        return !latestPage.isLastPage
    }

    private let _useCase: SearchRepoUseCase
    private var _latestPage: RepoSearchPage?
    private var _isFetching: Bool = false

    init(useCase: SearchRepoUseCase) {
        self._useCase = useCase
    }

    func search(query: String, completionHandler: @escaping FetchCompletionHandler) {
        // TODO: Add task cancelation
        guard !_isFetching else { return }

        _isFetching = true
        _latestPage = nil
        _items = []

        fetch(query: query, page: 1, completionHandler: completionHandler)
    }

    func nextPage(completionHandler: @escaping FetchCompletionHandler) {
        guard let latestPage = _latestPage, !latestPage.isLastPage && !_isFetching else { return }

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
                strongSelf._items += page.repos.map({ Item.repo($0) })
                completionHandler(.success((strongSelf._items, strongSelf.isNextPageAvailable)))
            case .failure(let error):
                completionHandler(.failure(error))
            }

            strongSelf._isFetching = false
        }
    }
}
