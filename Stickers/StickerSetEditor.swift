//
//  StickerSetEditor.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import SwiftUI

struct StickerSetEditor: View {
    
    @Binding var stickerSet: StickerSet
    var isNew: Bool
    @Binding var isPresented: Bool
    
    var isEmpty: Bool { stickerSet.stickers.isEmpty }
    
    @State var imagePickerPresented: Bool = false
    @State private var loadedImagesData: [Data] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack(alignment: .leading) {
                
                    if isEmpty {
                        Text("Start by adding your images").font(.headline)
                    }
                    
                    LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], alignment: .center, spacing: 4, pinnedViews: [], content: {
                        ForEach(stickerSet.stickers) { sticker in
                            if let data = sticker.imageData, let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
        //                            .frame(height: 128, alignment: .center)
                                    
                            }
                        }
                        
                        addImage
                        
                    })
                    
                    if !isEmpty {
                        Text("Tap images above to edit or remove").font(.headline)
                    }
                    
                    
                    Button(action: { print("add") }, label: {
                        Text("Add sticker")
                    })
                    
                    Button(action: { print("delete") }, label: {
                        Text("Delete Set")
                    })
                }
                .padding(.leading, 20)
                .padding(.trailing, 16)
            }
            .navigationBarTitle(isNew ? "New Set" : "")
            .navigationBarItems(trailing: Button("Done", action: { self.isPresented = false }))
        }
        
        
    }
    
    var addImage: some View {
        Button {
            imagePickerPresented = true
        } label: {
            gradient1.mask(Image(systemName: "plus.square").resizable().aspectRatio(1, contentMode: .fit))
                .frame(height: 128, alignment: .center)
                .opacity(0.8)
        }
        .sheet(isPresented: $imagePickerPresented, onDismiss: loadImage) {
            ImagePicker(loadedImagesData: $loadedImagesData)
        }
    }
    
    func loadImage() {
        guard !loadedImagesData.isEmpty else { return }
        print(loadedImagesData)
        let newStickers = loadedImagesData.map {
            Sticker(id: UUID(), imageData: $0)
        }
        stickerSet.stickers.append(contentsOf: newStickers)
        loadedImagesData = []
    }

    
}

struct StickerSetEditor_Previews: PreviewProvider {
    static var previews: some View {
        StickerSetEditor(stickerSet: .constant(Store.testEmpty.stickerSets.first!), isNew: true, isPresented: .constant(true))
//        StickerSetEditor(stickerSet: .constant(Store.testMany.stickerSets.first!), isNew: false, isPresented: .constant(true))
    }
}
