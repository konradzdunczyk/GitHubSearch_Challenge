//
//  RepoSerachViewModelError.swift
//  GitHubSearch_Challenge
//
//  Created by Zduńczyk Konrad on 20/10/2021.
//

import Foundation

enum RepoSerachViewModelError: Error {
    case nextPageUnavailable
    case fetchingInProgress
    case repoError(_ error: GitHubRepositoryError)
}

extension RepoSerachViewModelError: Equatable {
    static func == (lhs: RepoSerachViewModelError, rhs: RepoSerachViewModelError) -> Bool {
        switch (lhs, rhs) {
        case (.nextPageUnavailable, .nextPageUnavailable):
            return true
        case (.fetchingInProgress, .fetchingInProgress):
            return true
        case (.repoError(let lError), .repoError(let rError)):
            return lError == rError
        default:
            return false
        }
    }
}
