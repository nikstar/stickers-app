
import UIKit

struct Sticker: Identifiable, Hashable, Codable {
    
    
    var id: UUID
    
    var imageData: Data
    
    init(id: UUID, imageData: Data) {
        self.id = id
        self.imageData = imageData
    }
    
    enum CodingKeys: CodingKey {
        case id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.imageData = Data()
    }
}

extension Sticker {
    
    var uiImage: UIImage? {
        return UIImage(data: imageData)
    }
}
