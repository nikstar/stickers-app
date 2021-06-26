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
            HStack(alignment: .center, spacing: 16) {
                ForEach(stickerSet.stickers) { sticker in
                    if let data = sticker.imageData, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(height: 128, alignment: .center)
                            
                    }
                }
                if stickerSet.stickers.isEmpty {
                    noStickers
                }
            }
        }
    }
    
    var noStickers: some View {
        Image(systemName: "circle.dashed")
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .padding(6)
            .frame(height: 128, alignment: .center)
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


