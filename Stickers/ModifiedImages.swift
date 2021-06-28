//
//  Cache.swift
//  Stickers
//
//  Created by  nikstar on 28.06.2021.
//

import UIKit
import SwiftUI
import Combine

fileprivate let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
fileprivate let cacheDir = documents.appendingPathComponent("cache")

extension Store {
    fileprivate func sticker(id: UUID) -> Sticker {
        stickers.first { $0.id == id }!
    }
}

final class ModifiedImages {
    
    fileprivate var store: Store
    
    @Published fileprivate var stickers: [UUID: UIImage] = [:]
    
    init(store: Store) {
        self.store = store
    }
    
    func get(id: UUID) -> UIImage? {
        if let image = stickers[id] {
            return image
        } else if let data = try? Data(contentsOf: cacheDir.appendingPathComponent(id.uuidString)), let image = UIImage(data: data) {
            stickers[id] = image
            return image
        }
        let original = store.originalImages.get(id: id)
        guard var workImage = UIImage(data: original), let sticker = store.stickers.first(where: { $0.id == id }) else { return nil }

        for effect in sticker.effects {
            switch effect {
            case .removeBackground:
                workImage = RemoveBackgroundEffect.apply(to: workImage)
            }
        }
        stickers[id] = workImage
        DispatchQueue.global(qos: .utility).async {
            try! FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true, attributes: [:])
            try! workImage.pngData()!.write(to: cacheDir.appendingPathComponent(id.uuidString))
            self.store.modifiedImageCached(id: id)
        }
        return workImage
    }
    
    func invalidate(_ stickerID: UUID) {
        stickers[stickerID] = nil
        DispatchQueue.global(qos: .utility).async {
            try? FileManager.default.removeItem(at: cacheDir.appendingPathComponent(stickerID.uuidString))
        }
    }
}
