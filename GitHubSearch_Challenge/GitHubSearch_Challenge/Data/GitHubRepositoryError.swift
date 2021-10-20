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

extension GitHubRepositoryError: CustomStringConvertible {
    var description: String {
        switch self {
        case .wrongUrl:
            return "Wrong URL"
        case .wrongResponse:
            return "Wrong response"
        case .wrongData:
            return "Wrong response"
        case .validationFailed(message: let message):
            return "Validation failed with message: \(String(describing: message?.message))"
        case .serviceUnavailable:
            return "Service unavailable"
        case .unknown(error: let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

extension GitHubRepositoryError: Equatable {
    static func == (lhs: GitHubRepositoryError, rhs: GitHubRepositoryError) -> Bool {
        switch (lhs, rhs) {
        case (.wrongUrl, .wrongUrl):
            return true
        case (.serviceUnavailable, .serviceUnavailable):
            return true
        case (.wrongResponse, .wrongResponse):
            return true
        case (.wrongData, .wrongData):
            return true
        case (.validationFailed(let lMessage), .validationFailed(let rMessage)):
            return lMessage?.message == rMessage?.message
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}
