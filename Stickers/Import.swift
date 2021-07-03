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
        let convertedStickers = stickerSet.stickers.compactMap { stickerID -> StickerImport.Sticker? in
            guard let sticker = self.getSticker(id: stickerID) else { return nil }
            let emoji = sticker.emoji.map { "\($0)" }
            let image = foregroundCache.get(id: stickerID)
            guard let data = image.pngData() else { return nil }
            return StickerImport.Sticker(
                data: StickerImport.Sticker.StickerData.image(data),
                emojis: emoji
            )
        }
        try StickerImport.StickerSet(id: UUID(), software: "Stickers for Telegram", isAnimated: false, stickers: convertedStickers).import()
    }
}
