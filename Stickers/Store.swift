//
//  Store.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import SwiftUI
import Combine

fileprivate let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

final class Store: ObservableObject, Codable {

    @Published var stickerSets: [StickerSet]
    private var cancellables: Set<AnyCancellable> = []
    
    fileprivate init(stickerSets: [StickerSet]) {
        self.stickerSets = stickerSets
    }
    
    func startObservers() -> Self {
        $stickerSets
            .receive(on: DispatchQueue.global(qos: .utility))
            .removeDuplicates()
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .map(Store.init)
            .sink(receiveValue: writeToDisk(_:))
            .store(in: &cancellables)
        return self
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.stickerSets = try container.decode([StickerSet].self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stickerSets)
    }
    
    func binding(forStickerSet id: UUID) -> Binding<StickerSet> {
        Binding {
            if let stickerSet = self.stickerSets.first(where: { $0.id == id }) {
                return stickerSet
            } else {
                let stickerSet = StickerSet(id: id, stickers: [])
                self.stickerSets.insert(stickerSet, at: 0)
                return stickerSet
            }
        } set: { newValue in
            if let idx = self.stickerSets.firstIndex(where: { $0.id == id }) {
                self.stickerSets[idx] = newValue
            } else {
                self.stickerSets.insert(newValue, at: 0)
            }
        }

    }
    
    func binding(forSticker id: UUID, inSet: UUID) -> Binding<Sticker> {
        Binding {
            if let stickerSet = self.stickerSets.first(where: { $0.id == id }), let sticker = stickerSet.stickers.first(where: { $0.id == id }) {
                return sticker
            } else {
                // error
                return Sticker(id: UUID(), imageData: Data())
            }
        } set: { newValue in
            if let setIdx = self.stickerSets.firstIndex(where: { $0.id == id }), let idx = self.stickerSets[setIdx].stickers.firstIndex(where: { $0.id == id }) {
                self.stickerSets[setIdx].stickers[idx] = newValue
            } else {
                // error
//                self.stickerSets.insert(newValue, at: 0)
            }
        }

    }
    
}


func writeToDisk(_ store: Store) {
    do {
        let data = try JSONEncoder().encode(store)
        let dataFile = documents.appendingPathComponent("data.json")
        try data.write(to: dataFile)
        
        let imagesDir = documents.appendingPathComponent("images")
        try FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true, attributes: nil)
        let allStickers = store.stickerSets.flatMap(\.stickers)
        for sticker in allStickers {
            let url = imagesDir.appendingPathComponent(sticker.id.uuidString)
            if !FileManager.default.fileExists(atPath: url.path) {
                try sticker.imageData.write(to: url)
            }
        }
    } catch (let error) {
        print(error)
    }
}


extension Store {
    
    static func `default`() -> Store {
        do {
            let dataFile = documents.appendingPathComponent("data.json")
            let data = try Data(contentsOf: dataFile)
            let store = try JSONDecoder().decode(Store.self, from: data)
            let imagesDir = documents.appendingPathComponent("images")
            
            for (setIdx, set) in store.stickerSets.enumerated() {
                for (idx, sticker) in set.stickers.enumerated() {
                    let url = imagesDir.appendingPathComponent(sticker.id.uuidString)
                    let data = try Data(contentsOf: url)
                    store.stickerSets[setIdx].stickers[idx].imageData = data
                }
            }
            return store.startObservers()
        } catch (let error) {
            print(error)
            return Store.examples.startObservers()
        }
    }
    
    static var examples: Store {
        
        Store(stickerSets: [
            StickerSet(id: UUID(), stickers: [
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!)
            ])
        ])
    }
}


extension Store {
    
    static var testDefault: Store {
        Store(stickerSets: [
            StickerSet(id: UUID(), stickers: [
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!)
            ]),
            StickerSet(id: UUID(), stickers: [
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
            ]),
            StickerSet(id: UUID(), stickers: [
            ]),
            StickerSet(id: UUID(), stickers: [
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
            ]),
            StickerSet(id: UUID(), stickers: [
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!)
            ]),
            StickerSet(id: UUID(), stickers: [
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!)
            ]),
            StickerSet(id: UUID(), stickers: [
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
            ]),
            StickerSet(id: UUID(), stickers: [
            ]),
            StickerSet(id: UUID(), stickers: [
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!)
            ]),
            StickerSet(id: UUID(), stickers: [
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!)
            ]),
            StickerSet(id: UUID(), stickers: [
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
            ]),
            StickerSet(id: UUID(), stickers: [
            ]),
            StickerSet(id: UUID(), stickers: [
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!)
            ]),
            
        ])
    }
    
    static var testEmpty: Store {
        Store(stickerSets: [
            StickerSet(id: UUID(), stickers: [
            ])
        ])
    }
    
    static var testMany: Store {
        Store(stickerSets: [
            StickerSet(id: UUID(), stickers: [
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!),
            ].shuffled())
        ])
    }
    
}
