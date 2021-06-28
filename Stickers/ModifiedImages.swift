//
//  Cache.swift
//  Stickers
//
//  Created by  nikstar on 28.06.2021.
//

import UIKit
import SwiftUI
import Combine

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
        return workImage
    }
    
    func invalidate(_ stickerID: UUID) {
        stickers[stickerID] = nil
    }
}

