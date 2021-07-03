//
//  StickerSet.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import Foundation

struct StickerSet: Hashable, Codable {
    
    let id: UUID
    
    var type: SetType = .images
    var stickers: [UUID]
    
    enum SetType: String, Codable, Equatable {
        case images
        case animated
    }
}
