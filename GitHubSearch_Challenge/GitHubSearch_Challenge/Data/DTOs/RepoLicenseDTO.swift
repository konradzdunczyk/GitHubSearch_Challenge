import Foundation

// MARK: - RepoLicenseDTO
struct RepoLicenseDTO: Codable {
    let key: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case key = "key"
        case name = "name"
    }
}
