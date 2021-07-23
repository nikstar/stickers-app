
import UIKit

fileprivate let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("maskCache.json")
fileprivate let cacheDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("mask")

final class MaskCache {
    
    var store: Store
    
    var cache: [UUID: MaskConfig] {
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
        if let data = try? Data(contentsOf: fileURL), let cache = try? JSONDecoder().decode([UUID: MaskConfig].self, from: data) {
            self.cache = cache
        } else {
            self.cache = [:]
        }
        try! FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true, attributes: nil)
    }
    
    func isCurrent(id: UUID) -> Bool {
        if let cached = cache[id], store.getSticker(id: id)?.background.maskConfig == cached {
            return true
        }
        return false
    }
    
    func loadFromDisk(id: UUID) -> UIImage? {
        if let data = try? Data(contentsOf: cacheDir.appendingPathComponent(id.uuidString)), let image = UIImage(data: data) {
            return image
        }
        return nil
    }
    
    private func writeImageToDisk(id: UUID, image: UIImage) {
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
        let data = store.originalImages.get(id: id)
        guard let sticker = store.getSticker(id: id), var image = UIImage(data: data) else {
            // error
            return UIImage()
        }
        image = MaskEffect.apply(to: image, config: sticker.background.maskConfig)
        inMemory[id] = image
        cache[id] = sticker.background.maskConfig
        writeImageToDisk(id: id, image: image)
        return image
    }
    
    func updateCustom(id: UUID, image: UIImage) {
        inMemory[id] = image
        cache[id] = .custom
        writeImageToDisk(id: id, image: image)
    }
}
