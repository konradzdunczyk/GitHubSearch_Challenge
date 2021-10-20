//
//  Cancellable.swift
//  GitHubSearch_Challenge
//
//  Created by Zduńczyk Konrad on 19/10/2021.
//

import Foundation

// sourcery: AutoMockable
protocol Cancellable {
    func cancel()
}

extension URLSessionTask: Cancellable { }
