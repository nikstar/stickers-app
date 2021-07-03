//
//  Import.swift
//  Stickers
//
//  Created by  nikstar on 27.06.2021.
//

import Foundation
import StickerImport

extension Store {
    func export(_ stickerSet: StickerSet) throws {
        let type = stickerSet.type
        
        let convertedStickers = stickerSet.stickers.compactMap { id -> StickerImport.Sticker? in
            guard let sticker = self.getSticker(id: id) else { return nil }
            
            let emoji = sticker.emoji.map { "\($0)" }
            
            switch sticker.type {
            case .image:
                let image = foregroundCache.get(id: id)
                guard let data = image.pngData() else { return nil }
                return StickerImport.Sticker(
                    data: StickerImport.Sticker.StickerData.image(data),
                    emojis: emoji
                )
            
            case .animated:
                let url = originalImages.getURL(id: id)
                guard let data = try? Data(contentsOf: url) else { return nil }
                return StickerImport.Sticker(
                    data: StickerImport.Sticker.StickerData.animation(data),
                    emojis: emoji
                )
            }
        }
        try StickerImport.StickerSet(id: UUID(), software: "Stickers for Telegram", isAnimated: type == .animated, stickers: convertedStickers).import()
    }
}
