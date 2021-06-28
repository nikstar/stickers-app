//
//  StickerRow.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import SwiftUI


struct StickerRow: View {
    
    var stickerSet: StickerSet
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 12) {
                
                ForEach(stickerSet.stickers) { sticker in
                    ZStack {
                        if let data = sticker.imageData, let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            
                        }
//                        Color.orange.opacity(0.2)
                        Color.clear
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: 96, maxHeight: 96, alignment: .center)

                }
                if stickerSet.stickers.isEmpty {
                    noStickers
                    noStickers
                    noStickers
                    noStickers
                    noStickers
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 12)
        .background(Color.secondary.opacity(0.08))
    }
    
    var noStickers: some View {
        Image(systemName: "square.dashed")
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .padding(12)
            .frame(height: 96, alignment: .center)
            .opacity(0.2)
    }
}

struct StickerRow_Previews: PreviewProvider {
    static var previews: some View {
        StickerRow(stickerSet: Store.examples.stickerSets.first!)
            .previewLayout(.sizeThatFits)
        StickerRow(stickerSet: Store.testMany.stickerSets.first!)
            .previewLayout(.sizeThatFits)
        StickerRow(stickerSet: StickerSet(id: UUID(), stickers: []))
            .previewLayout(.sizeThatFits)
    }
}


