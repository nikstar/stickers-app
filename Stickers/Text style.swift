
import SwiftUI


extension Sticker {
    
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

    enum TextFont: String, Codable, CaseIterable, Hashable {
        case arial
        case comicSans
        case helvetica
        case impact
        case snellRoundhand
    }
    
}


extension Sticker.TextPosition {
    var localizedDescription: LocalizedStringKey {
        return LocalizedStringKey(rawValue.capitalized)
    }
}


extension Sticker.TextColor {
    var localizedDescription: LocalizedStringKey {
        switch self {
        case .white:
            return "White"
        case .whiteWithBorder:
            return  "White with black border"
        case .black:
            return "Black"
        case .blackWithBorder:
            return "Black with white border"
        case .yellow:
            return "Yellow"
        case .orange:
            return "Orange"
        case .blue:
            return "Blue"
        }
    }
}


extension Sticker.TextFont {
    var localizedDescription: LocalizedStringKey {
        switch self {
        case .arial:
            return "Arial"
        case .comicSans:
            return "Comic Sans"
        case .helvetica:
            return "Helvetica"
        case .impact:
            return "Impact"
        case .snellRoundhand:
            return "Fancy"
        }
    }
}


extension Sticker.TextFont: Cyclable, LocalizedDescription { }
extension Sticker.TextColor: Cyclable, LocalizedDescription { }
extension Sticker.TextPosition: Cyclable, LocalizedDescription { }
