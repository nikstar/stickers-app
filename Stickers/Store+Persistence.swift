//
//  Store+Persistence.swift
//  Stickers
//
//  Created by  nikstar on 28.06.2021.
//

import UIKit
import SwiftUI


fileprivate let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!


extension Store: Codable {
    
    enum CodingKeys: CodingKey {
        case stickerSets
        case stickers
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let stickerSets = try container.decode([StickerSet].self, forKey: .stickerSets)
        let stickers = try container.decode([Sticker].self, forKey: .stickers)
        self.init(stickerSets: stickerSets, stickers: stickers)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stickerSets, forKey: .stickerSets)
        try container.encode(stickers, forKey: .stickers)
    }
}


extension Store {
    static func `default`() -> Store {
        do {
            let dataFile = documents.appendingPathComponent("data.json")
            let data = try Data(contentsOf: dataFile)
            let store = try JSONDecoder().decode(Store.self, from: data)
            return store
        } catch (let error) {
            print(error)
            return Store.examples
        }
    }
    
    static var examples: Store {
        let store = Store(stickerSets: [], stickers: [])
        let set = UUID()
        store.addNewStickerSet(id: set)
        store.addNewSticker(id: UUID(), setID: set, data: UIImage(named: "s-1")!.pngData()!)
        store.addNewSticker(id: UUID(), setID: set, data: UIImage(named: "s-2")!.pngData()!)
        store.addNewSticker(id: UUID(), setID: set, data: UIImage(named: "s-3")!.pngData()!)
        return store
    }
    
    func writeToDisk() {
        do {
            let data = try JSONEncoder().encode(self)
            let dataFile = documents.appendingPathComponent("data.json")
            try data.write(to: dataFile)
            
            let imagesDir = documents.appendingPathComponent("images")
            try FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true, attributes: nil)
            
        } catch (let error) {
            print(error)
        }
    }
}

