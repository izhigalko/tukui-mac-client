import Foundation

struct Addon: Decodable {
    var id: String
    var name: String
    var downloadUrl: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case downloadUrl = "url"
    }
}
