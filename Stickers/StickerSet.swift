//
//  StickerSet.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import Foundation

struct StickerSet: Identifiable, Hashable, Codable {
    
    let id: UUID
    
    var stickers: [Sticker]
    
}
