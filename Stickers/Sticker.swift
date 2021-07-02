
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
    var color: TextColor = .whiteWithBorder
    
    var modifiedImageCached: Bool = false
    
    var effects: [Effect] {
        var effects: [Effect] = []
        if removeBackground {
            effects.append(.removeBackground(monochromeBackground: monochromeBackground, addBorder: addBorder))
        }
        effects.append(.resize)
        if !text.isEmpty {
            effects.append(.addText(text: text, position: position, font: font, color: color))
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
