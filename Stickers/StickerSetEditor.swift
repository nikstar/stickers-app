//
//  StickerSetEditor.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import SwiftUI

struct StickerSetEditor: View {

    @Binding var stickerSet: StickerSet
    @Binding var isPresented: Bool
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], alignment: .center, spacing: nil, pinnedViews: [], content: {
                ForEach(stickerSet.stickers) { sticker in
                    if let data = sticker.imageData, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
//                            .frame(height: 128, alignment: .center)
                            
                    }
                }
                
            })
            
            Button(action: { print("delete") }, label: {
                Text("Add sticker")
            })
            
            Button(action: { print("delete") }, label: {
                Text("Delete Set")
            })
            
        }
        
        
    }

}

struct StickerSetEditor_Previews: PreviewProvider {
    static var previews: some View {
        StickerSetEditor(stickerSet: .constant(Store.testMany.stickerSets.first!), isPresented: .constant(true))
    }
}
