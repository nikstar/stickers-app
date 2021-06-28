//
//  StickerEditor.swift
//  Stickers
//
//  Created by  nikstar on 28.06.2021.
//

import SwiftUI

struct StickerEditor: View {
    
    @EnvironmentObject var store: Store
    
    @Binding var sticker: Sticker

    var body: some View {
//        ScrollView {
//            Color.orange
            VStack(alignment: .leading, spacing: 8) {
                stickerPreview
                editOptions
            }
//        }
    }
    
    var stickerPreview: some View {
        Group {
            if let image = store.image(for: sticker.id) {
                ZStack {
                    Color.secondary.opacity(0.08)
                        .cornerRadius(30)
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(16)
                    
                }
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, 44)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
            }
        }
    }
    
    var editOptions: some View {
        List {
            Toggle("Remove background", isOn: $sticker.removeBackground)
            Text("Hello")
        }
        .background(Color.orange)
        .listStyle(GroupedListStyle())
    }
}



struct StickerEditor_Previews: PreviewProvider {
    static var previews: some View {
        let sticker = Sticker(id: UUID(), removeBackground: false)
        return StickerEditor(sticker: .constant(sticker))
            
    }
}
