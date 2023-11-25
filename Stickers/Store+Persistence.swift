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
        
        let _stickerSets = try container.decode([StickerSet].self, forKey: .stickerSets)
        
        // ensure unique ids
        var ids = Set<UUID>()
        var stickerSets = [StickerSet]()
        for stickerSet in _stickerSets {
            if ids.contains(stickerSet.id) == false {
                ids.insert(stickerSet.id)
                stickerSets.append(stickerSet)
            } else {
                print("duplicate sticker set!")
            }
        }
        
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
            let decoder = JSONDecoder()
            let store = try decoder.decode(Store.self, from: data)
            return store
        } catch (let error) {
            print(error)
            return Store.examples
        }
    }
    
    static var examples: Store {
        let store = Store(stickerSets: [], stickers: [])
        
        let chibi = UUID()
        store.addNewStickerSet(id: chibi)
        for i in 1...5 {
            let sticker = Sticker(id: UUID(), type: .image, emoji: "", background: .init(removeBackground: true, monochromeBackground: true, addBorder: true), foreground: .init())
            store.addNewSticker(sticker: sticker, set: chibi, data: UIImage(named: "chibi-\(i)")!.pngData()!)
        }
        
        let freddie = UUID()
        store.addNewStickerSet(id: freddie)
        for i in 1...3 {
            let bg: BackgroundConfig = i == 2 ? .init(removeBackground: true, monochromeBackground: false, addBorder: true) : .init()
            let fg: ForegroundConfig = i == 3 ? .init(text: "Champions", position: .bottom, font: .snellRoundhand, color: .yellow) : .init()
            let sticker = Sticker(id: UUID(), type: .image, emoji: "🙌", background: bg, foreground: fg)
            store.addNewSticker(sticker: sticker, set: freddie, data: UIImage(named: "freddie-\(i)")!.pngData()!)
        }
        
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

