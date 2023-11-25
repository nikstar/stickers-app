//
//  Import.swift
//  Stickers
//
//  Created by  nikstar on 27.06.2021.
//

import UIKit
import TelegramStickersImport

extension Store {
    func export(_ stickerSet: StickerSet) throws {
        
        let exportSet = TelegramStickersImport.StickerSet(software: "Sticker Maker for Telegram", type: stickerSet.type == .animated ? .animation : .image)
        
        for id in stickerSet.stickers {
            guard let sticker = self.getSticker(id: id) else { continue }
            let emoji = sticker.emoji.isEmpty ? [String(Character.randomEmoji())] : sticker.emoji.map { "\($0)" }
            
            switch sticker.type {
            case .image:
                let image = foregroundCache.get(id: id)
                guard var data = image.pngData() else { continue }
                if data.count > 512 * 1024 {
                    data = image.jpegData(compressionQuality: 1.0)!
                }
                if data.count > 512 * 1024 {
                    data = image.jpegData(compressionQuality: 0.9)!
                }
                if data.count > 512 * 1024 {
                    data = image.jpegData(compressionQuality: 0.75)!
                }
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
