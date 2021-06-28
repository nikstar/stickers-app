
import UIKit
import Vision

struct Sticker: Identifiable, Hashable, Codable {
    
    var id: UUID
    
    var removeBackground: Bool = false
    
    var modifiedImageCached: Bool = false
    
    var effects: [Effect] {
        var result: [Effect] = []
        if removeBackground { result.append(.removeBackground) }
        return result
    }
}
