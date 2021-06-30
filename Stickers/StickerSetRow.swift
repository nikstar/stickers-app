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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 12) {
                
                ForEach(stickerSet.stickers, id: \.self) { stickerID in
                    Group {
                    stickerView(stickerID)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 12)
        .background(Color.secondary.opacity(0.08))
    }
    
    func stickerView(_ stickerID: UUID) -> some View {
        ZStack {
            Color.clear
            if let image = store.image(for: stickerID) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 96, maxHeight: 96, alignment: .center)
    }
}

struct StickerRow_Previews: PreviewProvider {
    static var previews: some View {
        StickerSetRow(stickerSet: Store.examples.stickerSets.first!)
            .previewLayout(.sizeThatFits)
        StickerSetRow(stickerSet: Store.default().stickerSets.first!)
            .previewLayout(.sizeThatFits)
        StickerSetRow(stickerSet: StickerSet(id: UUID(), stickers: []))
            .previewLayout(.sizeThatFits)
    }
}


