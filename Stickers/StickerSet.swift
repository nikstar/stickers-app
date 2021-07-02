//
//  StickerSet.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import Foundation

struct StickerSet: Hashable, Codable {
    
    let id: UUID // not identifiable
    
    var stickers: [UUID]
    
}
