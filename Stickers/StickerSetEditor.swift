//
//  StickerSetEditor.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import SwiftUI

struct StickerSetEditor: View {
    
    @EnvironmentObject var store: Store
    
    @Binding var stickerSet: StickerSet
    var isNew: Bool
    @Binding var isPresented: Bool
    
    var isEmpty: Bool { stickerSet.stickers.isEmpty }
    
    @State var imagePickerPresented: Bool = false
    @State private var loadedImagesData: [Data] = []
    
    @State var stickerEditorPresented: Bool = false
    @State var presentedStickerID: (UUID, UUID)? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack(alignment: .leading) {
                    
                    if isEmpty {
                        Text("Start by adding your images").font(.headline)
                    }
                    
                    LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], alignment: .center, spacing: 4, pinnedViews: [], content: {
                        
                        ForEach(stickerSet.stickers) { sticker in
                            Button {
                                presentedStickerID = (stickerSet.id, sticker.id)
                            } label: {
                                stickerView(sticker)
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
                    
                    if !isEmpty {
                        importToTelegram
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 16)
            }
            .navigationBarTitle(isNew ? "New Set" : "")
            .navigationBarItems(trailing: Button("Done", action: { self.isPresented = false }))
            .onChange(of: presentedStickerID?.1) { id in
                if stickerEditorPresented == false {
                    stickerEditorPresented = id != nil
                }
            }
            .sheet(isPresented: $stickerEditorPresented) {
                if let id = presentedStickerID {
                    StickerEditor(sticker: store.binding(forSticker: id.1, inSet: id.0))
                } else {
                    Color.orange
                }
            }
            
        }
        
        
    }
    
    func stickerView(_ sticker: Sticker) -> some View {
        Group {
            if let data = sticker.imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(6)
                    //                            .frame(height: 128, alignment: .center)
                    .background(Color.secondary.opacity(0.08).cornerRadius(12))
            }
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
    
    var importToTelegram: some View {
        Button {
            `import`(stickerSet)
        } label: {
            Text("Import to Telegram")
                .font(.title.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 66, maxHeight: 66, alignment: .center)
                .background(
                    gradient1
                        .cornerRadius(24, antialiased: true)
                )
            //                .padding(.horizontal, 8)
        }
        .padding(.top, 22)
        .padding(.bottom, 10)
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
        //        StickerSetEditor(stickerSet: .constant(Store.testEmpty.stickerSets.first!), isNew: true, isPresented: .constant(true))
        StickerSetEditor(stickerSet: .constant(Store.testDefault.stickerSets.first!), isNew: false, isPresented: .constant(true))
            .environmentObject(Store.testDefault)
    }
}
