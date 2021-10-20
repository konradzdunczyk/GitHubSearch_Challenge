//
//  RepoSearchPage.swift
//  GitHubSearch_Challenge
//
//  Created by Zduńczyk Konrad on 13/10/2021.
//

import Foundation

struct RepoSearchPage: Equatable {
    let query: String
    let page: Int
    let allPages: Int
    let totalCount: Int
    let repos: [Repo]
}

extension RepoSearchPage {
    var isLastPage: Bool { page == allPages }
}
