//
//  Repo.swift
//  GitHubSearch_Challenge
//
//  Created by Zduńczyk Konrad on 13/10/2021.
//

import Foundation

struct Repo: Equatable {
    let id: Int
    let name: String
    let ownerName: String
    let htmlURL: String
    let licenseName: String?
}
