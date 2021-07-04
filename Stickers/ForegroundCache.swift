//
//  ForegroundCache.swift
//  Stickers
//
//  Created by  nikstar on 03.07.2021.
//

import UIKit

fileprivate let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("foregroundCache.json")
fileprivate let cacheDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("foreground")

struct _Config: Codable, Equatable {
    var background: BackgroundConfig
    var foreground: ForegroundConfig
}

final class ForegroundCache {
    
    var store: Store
    
    var cache: [UUID: _Config] {
        didSet {
            DispatchQueue.global(qos: .background).async {
                if let data = try? JSONEncoder().encode(self.cache) {
                    try? data.write(to: fileURL)
                }
            }
        }
    }
    var inMemory: [UUID: UIImage] = [:]
    
    init(store: Store) {
        self.store = store
        if let data = try? Data(contentsOf: fileURL), let cache = try? JSONDecoder().decode([UUID: _Config].self, from: data) {
            self.cache = cache
        } else {
            self.cache = [:]
        }
        try! FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true, attributes: nil)
    }
    
    func isCurrent(id: UUID) -> Bool {
        if let cached = cache[id], let sticker = store.getSticker(id: id) {
            return cached == _Config(background: sticker.background, foreground: sticker.foreground)
        }
        return false
    }
    
    func loadFromDisk(id: UUID) -> UIImage? {
        if let data = try? Data(contentsOf: cacheDir.appendingPathComponent(id.uuidString)), let image = UIImage(data: data) {
            return image
        }
        return nil
    }
    
    func writeImageToDisk(id: UUID, image: UIImage) {
        DispatchQueue.global(qos: .background).async {
            if let data = image.pngData() {
                try? data.write(to: cacheDir.appendingPathComponent(id.uuidString))
            }
        }
    }
    
    func get(id: UUID) -> UIImage {
        if isCurrent(id: id) {
            if let image = inMemory[id] {
                return image
            }
            if let image = loadFromDisk(id: id) {
                inMemory[id] = image
                return image
            }
        }
        var image = store.backgroundCache.get(id: id)
        guard let sticker = store.getSticker(id: id) else { return image }
        
        if !sticker.foreground.text.isEmpty {
            image = AddTextEffect.apply(to: image, text: sticker.foreground.text, position: sticker.foreground.position, font: sticker.foreground.font, color: sticker.foreground.color)
        }
        inMemory[id] = image
        cache[id] = _Config(background: sticker.background, foreground: sticker.foreground)
        writeImageToDisk(id: id, image: image)
        return image
    }
}
