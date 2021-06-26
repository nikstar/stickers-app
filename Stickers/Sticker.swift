
import UIKit

struct Sticker: Identifiable, Hashable, Codable {
    
    var id: UUID
    
    var imageData: Data
    
    // effects
    
}

extension Sticker {
    
    var uiImage: UIImage? {
        return UIImage(data: imageData)
    }
}
