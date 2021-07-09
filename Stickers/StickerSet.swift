//
//  StickerSet.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import Foundation
import SwiftUI

struct StickerSet: Hashable {
    
    let id: UUID
    
    var type: SetType = .images
    var stickers: [UUID]
    
    var commentKey: String? = nil
    
    enum SetType: String, Codable, Equatable {
        case images
        case animated
    }
}


extension StickerSet: Codable {
    
    enum CodingKeys: CodingKey {
        case id
        case type
        case stickers
        case commentKey
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let type = try container.decode(SetType.self, forKey: .type)
        let stickers = try container.decode([UUID].self, forKey: .stickers)
        let commentKey = try container.decodeIfPresent(String.self, forKey: .commentKey)
        self.init(id: id, type: type, stickers: stickers, commentKey: commentKey)
    }
}
