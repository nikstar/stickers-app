
import UIKit
import Vision

struct Sticker: Identifiable, Hashable, Codable {
    
    var id: UUID
    
    var removeBackground: Bool = false
    var addBorder: Bool = false
    
    var modifiedImageCached: Bool = false { didSet { print("\(id.uuidString.prefix(6)): cached \(modifiedImageCached)") } }
    
    var effects: [Effect] {
        var result: [Effect] = []
        if removeBackground { result.append(.removeBackground(addBorder: addBorder)) }
        return result
    }
}
