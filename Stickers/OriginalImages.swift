
import Foundation

fileprivate let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
fileprivate let imagesDir = documents.appendingPathComponent("images")


final class OriginalImages {
    
    private var cache: [UUID:Data] = [:]
    private var dictionaryQueue = DispatchQueue(label: "me.nikstar.Stickers.original-images")
    private var backgroundQueue = DispatchQueue(label: "me.nikstar.Stickers.original-images.write")
    
    func add(id: UUID, data: Data) {
        dictionaryQueue.sync {
            cache[id] = data
        }
        backgroundQueue.async {
            try! FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true, attributes: nil)
            try! data.write(to: imagesDir.appendingPathComponent(id.uuidString))
        }
    }
    
    func get(id: UUID) -> Data {
        dictionaryQueue.sync {
            if let data = cache[id] {
                return data
            }
            let data = try! Data(contentsOf: imagesDir.appendingPathComponent(id.uuidString))
            cache[id] = data
            return data
        }
    }
    
    
    func getURL(id: UUID) -> URL {
        return imagesDir.appendingPathComponent(id.uuidString)
    }
}
