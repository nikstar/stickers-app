//
//  StickerRow.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import SwiftUI


struct StickerSetRow: View {
    
    @EnvironmentObject var store: Store
    
    var stickerSet: StickerSet
    
    var body: some View {
        ZStack {
    
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundColor(Color.secondary.opacity(0.08))
                .shadow(radius: 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 12) {
                    
                    ForEach(stickerSet.stickers, id: \.self) { id in
                        Group {
                            if let sticker = store.getSticker(id: id) {
                                StickerView(sticker: sticker, size: 96, showEmoji: false)
                            }
                            
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 8)
    }
    
    func stickerView(_ stickerID: UUID) -> some View {
        ZStack {
            Color.clear
            switch stickerSet.type {
            case .images:
                if let image = store.image(for: stickerID) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            case .animated:
                Text("ANIMATED")
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 96, maxHeight: 96, alignment: .center)
    }
}

struct StickerRow_Previews: PreviewProvider {
    static var previews: some View {
        //        StickerSetRow(stickerSet: Store.examples.stickerSets.first!)
        //            .previewLayout(.sizeThatFits)
        StickerSetRow(stickerSet: Store.default().stickerSets.first!)
            .environmentObject(Store.default())
            .previewLayout(.sizeThatFits)
        //        StickerSetRow(stickerSet: StickerSet(id: UUID(), stickers: []))
        //            .previewLayout(.sizeThatFits)
    }
}


