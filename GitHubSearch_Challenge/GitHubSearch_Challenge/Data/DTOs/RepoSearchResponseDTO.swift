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
    func toDomain(withPage page: Int, andPageSize pageSize: Int, maxSearchItems: Int) -> RepoSearchPage {
        let allPages: Int = Int(ceil(Double(min(totalCount, maxSearchItems)) / Double(pageSize)))
        let repos: [Repo] = items.map({ $0.toDomain() })

        return RepoSearchPage(page: page,
                              allPages: allPages,
                              totalCount: totalCount,
                              repos: repos)
    }
}
