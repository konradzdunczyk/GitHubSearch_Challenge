//
//  RepoSerachTypes.swift
//  GitHubSearch_Challenge
//
//  Created by Zduńczyk Konrad on 19/10/2021.
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

