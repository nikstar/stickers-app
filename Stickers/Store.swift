//
//  Store.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import SwiftUI
import Combine
import Lottie
import Gzip

final class Store: ObservableObject {
    
    // MARK: Properties
    
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
    lazy var backgroundCache: BackgroundCache = BackgroundCache(store: self)
    lazy var foregroundCache: ForegroundCache = ForegroundCache(store: self)
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(stickerSets: [StickerSet], stickers: [Sticker]) {
        self.stickerSets = stickerSets
        self.stickers = stickers
    }
    
    
    // MARK: - List
    
    var listBinding: Binding<[StickerSet]> {
        Binding {
            self.stickerSets
        } set: { newValue in
            self.stickerSets = newValue
        }
    }
    
    
    // MARK: - Sticker sets
    
    func addNewStickerSet(id: UUID) {
        stickerSets.append(StickerSet(id: id, stickers: []))
    }
    
    func moveStickerSet(from: IndexSet, to: Int) {
        stickerSets.move(fromOffsets: from, toOffset: to)
    }
    
    func removeStickerSet(id: UUID) {
        stickerSets.removeAll(where: { $0.id == id })
    }
    
    func removeEmptyStickerSets() {
        stickerSets.removeAll(where: \.stickers.isEmpty)
    }
    
    func binding(forStickerSet id: UUID) -> Binding<StickerSet> {
        Binding {
            if let stickerSet = self.stickerSets.first(where: { $0.id == id }) {
                return stickerSet
            } else {
                let stickerSet = StickerSet(id: id, stickers: [])
                DispatchQueue.main.async { self.stickerSets.insert(stickerSet, at: 0) }
                return stickerSet
            }
        } set: { newValue in
            if let idx = self.stickerSets.firstIndex(where: { $0.id == id }) {
                DispatchQueue.main.async { self.stickerSets[idx] = newValue }
            } else {
                DispatchQueue.main.async { self.stickerSets.insert(newValue, at: 0) }
            }
        }
    }
    
    
    // MARK: - Stickers
    
    func getSticker(id: UUID) -> Sticker? {
        return stickers.first { $0.id == id }
    }
    
    func addNewSticker(id: UUID, setID: UUID, data: Data) {
        originalImages.add(id: id, data: data)
        stickers.append(Sticker(id: id))
        if let setIndex = stickerSets.firstIndex(where: { $0.id == setID}) {
            stickerSets[setIndex].stickers.append(id)
        }
    }
    
    func addNewSticker(sticker: Sticker, set: UUID, data: Data) {
        originalImages.add(id: sticker.id, data: data)
        stickers.append(sticker)
        if let setIndex = stickerSets.firstIndex(where: { $0.id == set}) {
            stickerSets[setIndex].stickers.append(sticker.id)
        }
    }
    
    
    func removeSticker(id: UUID) {
        // TODO: remove files
        for idx in stickerSets.indices {
            stickerSets[idx].stickers.removeAll(where: { $0 == id })
        }
//        stickers.removeAll(where: { $0.id == id })
        // FIXME: check out why this doesn't quite work. Maybe remove on launch or something?
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
            } else {
                // error
                self.stickers.insert(newValue, at: 0)
            }
        }
    }
    
    
    func image(for stickerID: UUID) -> UIImage? {
        foregroundCache.get(id: stickerID)
    }
        
    
    // MARK: - Animated stickers
    
    func addNewAnimatedSticker(id: UUID = UUID(), setID: UUID, url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        let data = try! Data(contentsOf: url)
        originalImages.add(id: id, data: data)
        stickers.append(Sticker(id: id, type: .animated))
        if let setIndex = stickerSets.firstIndex(where: { $0.id == setID}) {
            stickerSets[setIndex].stickers.append(id)
        }
    }
    
    func getAnimated(id: UUID) -> LottieAnimation? {
        do {
            let url = originalImages.getURL(id: id)
            let data = try Data(contentsOf: url)
            let unzipped = try data.gunzipped()
            let animation = try JSONDecoder().decode(LottieAnimation.self, from: unzipped)
            return animation
        } catch {
            return nil
        }
    }
}

