import Foundation

// MARK: RepoSearchResponseDTO
struct RepoSearchResponseDTO: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [RepoDTO]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items = "items"
    }
}

extension RepoSearchResponseDTO {
    func toDomain(withQuery query: String, page: Int,
                  pageSize: Int, andMaxSearchItems maxSearchItems: Int) -> RepoSearchPage {
        let allPages: Int = Int(ceil(Double(min(totalCount, maxSearchItems)) / Double(pageSize)))
        let repos: [Repo] = items.map({ $0.toDomain() })

        return RepoSearchPage(query: query,
                              page: page,
                              allPages: allPages,
                              totalCount: totalCount,
                              repos: repos)
    }
}
