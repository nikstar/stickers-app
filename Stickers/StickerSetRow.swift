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


