
import UIKit
import Vision

struct Sticker: Identifiable, Hashable, Codable {
    
    var id: UUID
    
    var emoji: String = ""
    
    var removeBackground: Bool = false
    var monochromeBackground: Bool = false
    var addBorder: Bool = false
    
    var text: String = ""
    var position: TextPosition = .bottom
    var font: TextFont = .arial
    
    var modifiedImageCached: Bool = false { didSet { print("\(id.uuidString.prefix(6)): cached \(modifiedImageCached)") } }
    
    var effects: [Effect] {
        var effects: [Effect] = []
        if removeBackground {
            effects.append(.removeBackground(monochromeBackground: monochromeBackground, addBorder: addBorder))
        }
        effects.append(.resize)
        if !text.isEmpty {
            effects.append(.addText(text: text, position: position, font: font))
        }
        return effects
    }
    
    enum TextFont: String, Codable, CaseIterable, Hashable {
        case arial = "Arial"
        case impact = "Impact"
    }
    
    enum TextPosition: String, Codable, CaseIterable, Hashable {
        case top
        case middle
        case bottom
    }
}
