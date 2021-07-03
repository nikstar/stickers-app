//
//  ForegroundConfig.swift
//  Stickers
//
//  Created by  nikstar on 03.07.2021.
//

import Foundation


struct ForegroundConfig: Codable, Equatable, Hashable {
    var text: String = ""
    var position: Sticker.TextPosition = .bottom
    var font: Sticker.TextFont = .arial
    var color: Sticker.TextColor = .whiteWithBorder
}
