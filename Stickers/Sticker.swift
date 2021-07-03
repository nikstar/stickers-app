
import UIKit
import Vision

struct Sticker: Hashable, Codable {
    
    var id: UUID
    
    var emoji: String = ""
    
    var background: BackgroundConfig = .init()
    var foreground: ForegroundConfig = .init()
    
    var modifiedImageCached: Bool = false
    
    enum TextFont: String, Codable, CaseIterable, Hashable {
        case arial
        case comicSans
        case helvetica
        case impact
        case snellRoundhand
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


