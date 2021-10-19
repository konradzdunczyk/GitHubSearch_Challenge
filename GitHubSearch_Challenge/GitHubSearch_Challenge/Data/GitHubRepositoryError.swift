//
//  GitHubRepositoryError.swift
//  GitHubSearch_Challenge
//
//  Created by Zduńczyk Konrad on 13/10/2021.
//

import Foundation

enum GitHubRepositoryError: Error {
    struct ValidationMessage: Codable {
        let message: String

        enum CodingKeys: String, CodingKey {
            case message = "message"
        }
    }

    case wrongUrl
    case wrongResponse(response: URLResponse?, error: Error?)
    case wrongData(data: Data, error: Error)
    case validationFailed(message: ValidationMessage?)
    case serviceUnavailable
    case unknown(error: Error)
}
