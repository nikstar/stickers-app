//
//  Effect.swift
//  Stickers
//
//  Created by  nikstar on 28.06.2021.
//

import Foundation

enum Effect {
    case removeBackground(monochromeBackground: Bool, addBorder: Bool)
    case resize
    case addText(text: String, position: Sticker.TextPosition, font: Sticker.TextFont, color: Sticker.TextColor)
}
