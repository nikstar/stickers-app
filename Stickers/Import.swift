//
//  Import.swift
//  Stickers
//
//  Created by  nikstar on 27.06.2021.
//

import Foundation
import StickerImport

func `import`(_ stickerSet: StickerSet) {
    do {
        let convertedStickers = stickerSet.stickers.map { sticker -> StickerImport.Sticker in
            let data = sticker.imageData
            return StickerImport.Sticker(
                data: StickerImport.Sticker.StickerData.image(data),
                emojis: []
            )
        }
        try StickerImport.StickerSet(id: UUID(), software: "Stickers for Telegram", isAnimated: false, stickers: convertedStickers).import()
    } catch (let error) {
        print(error)
    }
}
