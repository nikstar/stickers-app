//
//  Store.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import SwiftUI
import Combine


final class Store: ObservableObject {

    @Published private(set) var stickerSets: [StickerSet] {
        didSet {
            writeToDisk()
        }
    }
    @Published private(set) var stickers: [Sticker] {
        didSet {
            writeToDisk()
        }
    }
    
    
    var originalImages: OriginalImages = OriginalImages()
    lazy var modifiedImages: ModifiedImages = ModifiedImages(store: self)
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(stickerSets: [StickerSet], stickers: [Sticker]) {
        self.stickerSets = stickerSets
        self.stickers = stickers
//        $stickerSets
//            .receive(on: DispatchQueue.global(qos: .utility))
//            .removeDuplicates()
//            .debounce(for: 0.1, scheduler: RunLoop.main)
//            .sink { _ in
//                self.writeToDisk()
//            }
//            .store(in: &cancellables)
//        $stickers
//            .receive(on: DispatchQueue.global(qos: .utility))
//            .removeDuplicates()
//            .debounce(for: 0.1, scheduler: RunLoop.main)
//            .sink { _ in
//                self.writeToDisk()
//            }
//            .store(in: &cancellables)
        
    }
    
    func addNewStickerSet(id: UUID) {
        stickerSets.append(StickerSet(id: id, stickers: []))
    }
    
    func removeStickerSet(id: UUID) {
        stickerSets.removeAll(where: { $0.id == id })
    }
    
    func addNewSticker(id: UUID, setID: UUID, data: Data) {
        originalImages.add(id: id, data: data)
        stickers.append(Sticker(id: id, removeBackground: false))
        if let setIndex = stickerSets.firstIndex(where: { $0.id == setID}) {
            stickerSets[setIndex].stickers.append(id)
        }
        
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
    
    func binding(forSticker id: UUID) -> Binding<Sticker> {
        Binding {
            if let sticker = self.stickers.first(where: { $0.id == id }) {
                return sticker
            } else {
                // error
                return Sticker(id: UUID())
            }
        } set: { newValue in
            if let idx = self.stickers.firstIndex(where: { $0.id == id }) {
                self.stickers[idx] = newValue
                self.modifiedImages.invalidate(id)
            } else {
                // error
                self.stickers.insert(newValue, at: 0)
            }
        }

    }
    
    
    func image(for stickerID: UUID) -> UIImage? {
        modifiedImages.get(id: stickerID)
    }
}

