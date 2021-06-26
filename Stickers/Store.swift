//
//  Store.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import SwiftUI
import Combine

final class Store: ObservableObject, Codable {

    @Published var stickerSets: [StickerSet]
    private var cancellables: Set<AnyCancellable> = []
    
    fileprivate init(stickerSets: [StickerSet]) {
        self.stickerSets = stickerSets
        
        $stickerSets
            .receive(on: DispatchQueue.global(qos: .utility))
            .removeDuplicates()
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .map(Store.init)
            .sink(receiveValue: writeToDisk(_:))
            .store(in: &cancellables)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.stickerSets = try container.decode([StickerSet].self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stickerSets)
    }
    
    func binding(for id: UUID) -> Binding<StickerSet> {
        Binding {
            if let stickerSet = self.stickerSets.first(where: { $0.id == id }) {
                return stickerSet
            } else {
                let stickerSet = StickerSet(id: id, stickers: [])
                self.stickerSets.append(stickerSet)
                return stickerSet
            }
        } set: { newValue in
            if let idx = self.stickerSets.firstIndex(where: { $0.id == id }) {
                self.stickerSets[idx] = newValue
            } else {
                self.stickerSets.append(newValue)
            }
        }

    }
}


func writeToDisk(_ store: Store) {
//    guard let data = try? JSONEncoder().encode(store) else { return }
//    UserDefaults.standard.set(data, forKey: "store")
    print("write")
}


extension Store {
    
    static var examples: Store {
        
        Store(stickerSets: [
            StickerSet(id: UUID(), stickers: [
                Sticker(id: UUID(), imageData: UIImage(named: "s-1")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-2")!.pngData()!),
                Sticker(id: UUID(), imageData: UIImage(named: "s-3")!.pngData()!)
            ])
        ])
    }
    
    static func `default`() -> Store {
//        if let data = UserDefaults.standard.data(forKey: "store"), let store = try? JSONDecoder().decode(Store.self, from: data) {
//            return store
//        }
//        return Store.examples
        return .testDefault
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
