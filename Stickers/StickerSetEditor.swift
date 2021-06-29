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
    
    // MARK: - Views
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    if isEmpty {
                        Text("Start by adding your images").font(.headline)
                    }
                    grid
                    if !isEmpty {
                        Text("Tap images above to edit or remove").font(.headline)
                        importToTelegram
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 16)
            }
            .navigationBarTitle(isNew ? "New Set" : "")
            .navigationBarItems(trailing: Button("Done", action: { self.isPresented = false }))
            
        }
        .onChange(of: presentedStickerID?.1) { id in
            if stickerEditorPresented == false {
                stickerEditorPresented = id != nil
            }
        }
        .onChange(of: imagePickerPresented, perform: { value in
            print("imagePickerPresented: \(value)")
        })
        .sheet(isPresented: $imagePickerPresented, onDismiss: loadImage) {
            ImagePicker(loadedImagesData: $loadedImagesData).environmentObject(store)
        }
        .sheet(isPresented: $stickerEditorPresented, onDismiss: {
            presentedStickerID = nil
        }) {
            if let id = presentedStickerID {
                StickerEditor(sticker: store.binding(forSticker: id.1)).environmentObject(store)
            } else {
                Color.red
            }
        }
        .environmentObject(store) // crashes without it. bug?
    }
    
    var grid: some View {
        LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], alignment: .center, spacing: 4, pinnedViews: [], content: {
            
            ForEach(stickerSet.stickers, id: \.self) {  stickerID in
                Button {
                    presentedStickerID = (stickerSet.id, stickerID)
                } label: {
                    stickerView(stickerID)
                }
            }
            addImage
            
        })
    }
    
    func stickerView(_ sticker: UUID) -> some View {
        ZStack {
            Color.secondary.opacity(0.08)
                .cornerRadius(12)
            if let image = store.image(for: sticker) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(6)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    var addImage: some View {
        Button {
            imagePickerPresented = true
        } label: {
            gradient1.mask(
                Image(systemName: "plus.square")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            )
            .aspectRatio(1, contentMode: .fit)
            .padding(4)
        }
    }
    
    var importToTelegram: some View {
        Button {
            store.export(stickerSet)
        } label: {
            Text("Import to Telegram")
                .font(.title.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 66, maxHeight: 66, alignment: .center)
                .background(
                    gradient1
                        .cornerRadius(24, antialiased: true)
                )
        }
        .padding(.top, 22)
        .padding(.bottom, 10)
    }
    
    
}


// MARK: - Actions

extension StickerSetEditor {
    
    func loadImage() {
        guard !loadedImagesData.isEmpty else { return }
        print(loadedImagesData)
        loadedImagesData.forEach { data in
            store.addNewSticker(id: UUID(), setID: stickerSet.id, data: data)
        }
        loadedImagesData = []
    }
}


// MARK: - Preview

struct StickerSetEditor_Previews: PreviewProvider {
    static var previews: some View {
        //        StickerSetEditor(stickerSet: .constant(Store.testEmpty.stickerSets.first!), isNew: true, isPresented: .constant(true))
        StickerSetEditor(stickerSet: .constant(Store.default().stickerSets.first!), isNew: false, isPresented: .constant(true))
            .environmentObject(Store.default())
    }
}
