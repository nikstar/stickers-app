
import UIKit
import Vision

struct Sticker: Hashable, Codable {
    
    var id: UUID
    
    var type: StickerType = .image
    
    var emoji: String = ""
    
    var background: BackgroundConfig = .init()
    var foreground: ForegroundConfig = .init()
    
    enum StickerType: String, Codable, Equatable {
        case image
        case animated
    }
}


