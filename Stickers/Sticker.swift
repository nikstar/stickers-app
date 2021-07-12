
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
    
    
    
    enum TextPosition: String, Codable, CaseIterable, Hashable {
        case top
        case middle
        case bottom
    }
    
    enum TextColor: String, Codable, CaseIterable, Hashable {
        case white
        case whiteWithBorder
        case black
        case blackWithBorder
        case yellow
        case orange
        case blue
    }
}


