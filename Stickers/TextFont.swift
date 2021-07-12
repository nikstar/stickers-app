//
//  TextFont.swift
//  Stickers
//
//  Created by  nikstar on 12.07.2021.
//

import SwiftUI


extension Sticker {
    
    enum TextFont: String, Codable, CaseIterable, Hashable {
        case arial
        case comicSans
        case helvetica
        case impact
        case snellRoundhand
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
