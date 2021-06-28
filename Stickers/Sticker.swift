
import UIKit
import Vision

struct Sticker: Identifiable, Hashable, Codable {
    
    var id: UUID
    var removeBackground: Bool
    
    var effects: [Effect] {
        var result: [Effect] = []
        if removeBackground { result.append(.removeBackground) }
        return result
    }
    
    init(id: UUID, removeBackground: Bool = false) {
        self.id = id
        self.removeBackground = removeBackground
    }
    
//    enum CodingKeys: CodingKey {
//        case id
//        case removeBackground
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(id, forKey: .id)
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(UUID.self, forKey: .id)
//        self.removeBackground = try container.decode(Bool.self, forKey: .removeBackground)
//    }
}
