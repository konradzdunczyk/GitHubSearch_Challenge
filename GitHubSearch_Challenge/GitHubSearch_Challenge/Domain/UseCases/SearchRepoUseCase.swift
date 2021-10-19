//
//  SearchRepoUseCase.swift
//  GitHubSearch_Challenge
//
//  Created by Zduńczyk Konrad on 13/10/2021.
//

import Foundation

protocol SearchRepoUseCase {
    func execute(requestValue: SearchRepoUseCaseRequestValue,
                 completion: @escaping (Result<RepoSearchPage, GitHubRepositoryError>) -> Void) -> Cancellable?
}

final class DefaultSearchRepoUseCase: SearchRepoUseCase {
    private let gitHubRepository: GitHubRepository

    init(gitHubRepository: GitHubRepository) {
        self.gitHubRepository = gitHubRepository
    }

    func execute(requestValue: SearchRepoUseCaseRequestValue,
                 completion: @escaping (Result<RepoSearchPage, GitHubRepositoryError>) -> Void) -> Cancellable? {
        gitHubRepository.fetchRepositoriesList(query: requestValue.query,
                                               page: requestValue.page,
                                               completion: completion)
    }
}

struct SearchRepoUseCaseRequestValue {
    let query: String
    let page: Int
}
