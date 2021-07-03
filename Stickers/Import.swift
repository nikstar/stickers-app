//
//  Import.swift
//  Stickers
//
//  Created by  nikstar on 27.06.2021.
//

import Foundation
import TelegramStickersImport

extension Store {
    func export(_ stickerSet: StickerSet) throws {
        
        let exportSet = TelegramStickersImport.StickerSet(software: "Sticker Maker for Telegram", isAnimated: stickerSet.type == .animated)
        
        for id in stickerSet.stickers {
            guard let sticker = self.getSticker(id: id) else { continue }
            let emoji = sticker.emoji.map { "\($0)" }
            
            switch sticker.type {
            case .image:
                let image = foregroundCache.get(id: id)
                guard let data = image.pngData() else { continue }
                try exportSet.addSticker(data: .image(data), emojis: emoji)
                
            default:
                let url = originalImages.getURL(id: id)
                guard let data = try? Data(contentsOf: url) else { continue }
                try exportSet.addSticker(data: .animation(data), emojis: emoji)
            }
        }
        
        try exportSet.import()
    }
}
