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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            self.id = String(try container.decode(Int.self, forKey: .id))
        } catch DecodingError.typeMismatch {
            self.id = try container.decode(String.self, forKey: .id)
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.downloadUrl = try container.decode(String.self, forKey: .downloadUrl)
    }
}
