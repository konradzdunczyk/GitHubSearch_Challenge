//
//  GitHubRepository.swift
//  GitHubSearch_Challenge
//
//  Created by Zduńczyk Konrad on 13/10/2021.
//

import Foundation

// sourcery: AutoMockable
protocol GitHubRepository {
    func fetchRepositoriesList(query: String,
                               page: Int,
                               completion: @escaping (Result<RepoSearchPage, GitHubRepositoryError>) -> Void) -> Cancellable?
}

class DefaultGitHubRepository: GitHubRepository {
    let pageSize: Int

    // "To satisfy that need, the GitHub Search API provides up to 1,000 results for each search."
    // https://docs.github.com/en/rest/reference/search
    let maxSearchItems: Int = 1000

    private let _urlSession: URLSession = URLSession.shared
    private let _jsonDecoder: JSONDecoder = {
        $0.dateDecodingStrategy = .iso8601

        return $0
    }(JSONDecoder())

    init(pageSize: Int = 30) {
        self.pageSize = max(min(pageSize, 100), 0)
    }

    func fetchRepositoriesList(query: String, page: Int, completion: @escaping (Result<RepoSearchPage, GitHubRepositoryError>) -> Void) -> Cancellable? {
        var urlComponents = URLComponents(string: "https://api.github.com/search/repositories")
        urlComponents?.queryItems = [
            .init(name: "q", value: query),
            .init(name: "sort", value: "stars"),
            .init(name: "order", value: "desc"),
            .init(name: "per_page", value: "\(pageSize)"),
            .init(name: "page", value: "\(page)")
        ]

        guard let url = urlComponents?.url else {
            completion(.failure(GitHubRepositoryError.wrongUrl))
            return nil
        }

        var urlReq = URLRequest(url: url,
                                timeoutInterval: 15)
        urlReq.httpMethod = "GET"
        urlReq.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        let task = _urlSession.dataTask(with: urlReq) { [_jsonDecoder, pageSize, maxSearchItems] data, response, error in
            if let error = error {
                completion(.failure(GitHubRepositoryError.unknown(error: error)))
                return
            }

            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(GitHubRepositoryError.wrongResponse(response: response, error: error)))
                return
            }

            switch httpResponse.statusCode {
            case 200:
                break
            case 422:
                let message = try? _jsonDecoder.decode(GitHubRepositoryError.ValidationMessage.self, from: data)
                completion(.failure(GitHubRepositoryError.validationFailed(message: message)))
                return
            default:
                completion(.failure(GitHubRepositoryError.serviceUnavailable))
                return
            }

            do {
                let repoSearchResp = try _jsonDecoder.decode(RepoSearchResponseDTO.self, from: data)
                completion(.success(repoSearchResp.toDomain(withQuery: query,
                                                            page: page,
                                                            pageSize: pageSize,
                                                            andMaxSearchItems: maxSearchItems)))
            } catch {
                completion(.failure(GitHubRepositoryError.wrongData(data: data, error: error)))
                return
            }
        }

        task.resume()

        return task
    }
}
