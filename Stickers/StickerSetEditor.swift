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
    
    var isEmpty: Bool { stickerSet.stickers.isEmpty }
    
    @State var imagePickerPresented: Bool = false
    @State private var loadedImagesData: [Data] = []
    
    @State var stickerEditorPresented: Bool = false
    @State var presentedStickerID: (UUID, UUID)? = nil
    
    @State var deleteAlertPresented = false
    
    @EnvironmentObject var store: Store
    @Environment(\.presentationMode) var presentationMode
    
    
    // MARK: - Views
    
    var body: some View {
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
            .padding(.top, 60)
            .padding(.leading, 20)
            .padding(.trailing, 16)
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
        .overlay(HStack {
            SmallButton(text: "Delete", color: .red) {
               deleteAlertPresented = true
            }
            Spacer()
            SmallButton(text: "Done", color: .blue) {
                presentationMode.wrappedValue.dismiss()
            }
            
        }.padding(2)
        , alignment: .top)
        .alert(isPresented: $deleteAlertPresented) {
            Alert(
                title: Text("Delete sticker set"),
                message: Text("Are you sure you want to delete this sticker set? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    store.removeStickerSet(id: stickerSet.id)
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        
        
        
        .environmentObject(store) // crashes without it. bug in Swift UI?
        
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
        print(sticker)
        return ZStack {
            Color.secondary.opacity(0.08)
                .cornerRadius(12)
            if let image = store.image(for: sticker) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(6)
            }
        }
        .overlay(Group {
            if let emoji = store.getSticker(id: sticker)?.emoji, emoji.count > 0 {
                Text(emoji.prefix(3)) // improve?
                    .padding(8)
            }
        }, alignment: .bottomTrailing)
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
        .shadow(radius: 10)
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
        StickerSetEditor(stickerSet: .constant(Store.default().stickerSets.first!), isNew: false)
            .environmentObject(Store.default())
    }
}
