import Foundation

// MARK: - RepoDTO
struct RepoDTO: Codable {
    let id: Int
    let nodeID: String
    let name: String
    let fullName: String
    let owner: RepoOwnerDTO
    let isPrivate: Bool
    let htmlURL: String
    let itemDescription: String?
    let fork: Bool
    let url: String
    let createdAt: Date
    let updatedAt: Date
    let pushedAt: Date
    let size: Int
    let stargazersCount: Int
    let watchersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let score: Int
    let archived: Bool
    let disabled: Bool
    let visibility: String
    let license: RepoLicenseDTO?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case nodeID = "node_id"
        case name = "name"
        case fullName = "full_name"
        case owner = "owner"
        case isPrivate = "private"
        case htmlURL = "html_url"
        case itemDescription = "description"
        case fork = "fork"
        case url = "url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case pushedAt = "pushed_at"
        case size = "size"
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
        case score = "score"
        case archived = "archived"
        case disabled = "disabled"
        case visibility = "visibility"
        case license = "license"
    }
}

extension RepoDTO {
    func toDomain() -> Repo {
        return .init(id: id,
                     name: name,
                     ownerName: owner.login,
                     htmlURL: htmlURL,
                     licenseName: license?.name)
    }
}
