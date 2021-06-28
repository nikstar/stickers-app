//
//  StickerEditor.swift
//  Stickers
//
//  Created by  nikstar on 28.06.2021.
//

import SwiftUI

struct StickerEditor: View {
    
    @Binding var sticker: Sticker

    var body: some View {
        ScrollView {
            Color.orange
            VStack(alignment: .leading, spacing: nil) {
                stickerPreview
            }
        }
    }
    
    var stickerPreview: some View {
        Group {
            if let data = sticker.imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .padding(16)
    //                            .frame(height: 128, alignment: .center)
                    .background(Color.secondary.opacity(0.08).cornerRadius(24))
                    .padding(.horizontal, 16)
            }
        }
    }
}

struct StickerEditor_Previews: PreviewProvider {
    static var previews: some View {
        let setID = Store.testDefault.stickerSets[0].id
        let id = Store.testDefault.stickerSets[0].stickers[0].id
        StickerEditor(sticker: Store.testDefault.binding(forSticker: id, inSet: setID))
            .environmentObject(Store.testDefault)
    }
}
