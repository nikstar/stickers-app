//
//  StickerSetEditor.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import SwiftUI
import SwiftUIX
import StickerImport

struct StickerSetEditor: View {
    
    @Binding var stickerSet: StickerSet
    var isNew: Bool
    
    var isEmpty: Bool { stickerSet.stickers.isEmpty }
    
    enum CellContent: Hashable {
        case sticker(Sticker)
        case newSticker
    }
    var cells: [CellContent] {
        stickerSet.stickers.compactMap(store.getSticker).map(CellContent.sticker) + [CellContent.newSticker]
    }
    @State var containerSize: CGSize = .init(width: 200, height: 200)
    var padding: CGFloat = 8
    var spacing: CGFloat = 8
    private var cellSize: CGFloat {
        ((containerSize.width - 2 * padding - 2 * spacing) / 3).rounded(.down)
    }
    private var collectionViewHeight: CGFloat {
        cellSize * CGFloat((cells.count - 1) / 3 + 1) + spacing * CGFloat((cells.count - 1) / 3)
    }
    
    @State var imagePickerPresented: Bool = false
    @State private var loadedImagesData: [Data] = []
    
    @State var stickerEditorPresented: Bool = false
    @State var presentedStickerID: (UUID, UUID)? = nil
    
    enum AlertContent {
        case deleteConfirmation
        case error
    }
    @State var alertPresented = false
    @State var alertContent: AlertContent = .error
    @State var errorMessage = "Error"
    @State var errorDescription = "Unknown error."
    
    @EnvironmentObject var store: Store
    @Environment(\.presentationMode) var presentationMode
    
    
    // MARK: - Views
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                
                if isNew {
                    Text("New Set").font(.largeTitle.bold())
                        .padding(.leading, 20)
                        .padding(.trailing, 16)
                }
                
                if isEmpty {
                    Text("Start by adding your images").font(.headline)
                        .padding(.leading, 20)
                        .padding(.trailing, 16)
                }
                
                grid
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                    .padding(.horizontal, padding)

                if !isEmpty {
                    Text("Tap images to edit or remove. Drag to reorder.").font(.headline)
                        .padding(.leading, 20)
                        .padding(.trailing, 16)
                    importToTelegram
                        .padding(.leading, 20)
                        .padding(.trailing, 16)
                }
            }
            .padding(.top, 60)
        }
        .overlay(HStack {
            SmallButton(text: "Delete", color: .red) {
                alertContent = .deleteConfirmation
                alertPresented = true
            }
            Spacer()
            SmallButton(text: "Done", color: .blue) {
                presentationMode.wrappedValue.dismiss()
            }
            
        }.padding(2)
        , alignment: .top)
        .onChange(of: presentedStickerID?.1) { id in
            if stickerEditorPresented == false {
                stickerEditorPresented = id != nil
            }
        }
        .sheet(isPresented: $imagePickerPresented, onDismiss: loadImage) {
            ImagePicker(loadedImagesData: $loadedImagesData).environmentObject(store)
        }
        .sheet(isPresented: $stickerEditorPresented, onDismiss: {
            if let id = presentedStickerID?.1 {
                presentedStickerID = nil
                let temp = UUID()
                stickerSet.stickers.append(temp)
                stickerSet.stickers.removeLast()
            }
        }) {
            if let id = presentedStickerID {
                StickerEditor(sticker: store.binding(forSticker: id.1)).environmentObject(store)
            } else {
                Color.red
            }
        }
        .alert(isPresented: $alertPresented) {
            switch alertContent {
            case .deleteConfirmation:
                return Alert(
                    title: Text("Delete sticker set"),
                    message: Text("Are you sure you want to delete this sticker set? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        store.removeStickerSet(id: stickerSet.id)
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            case .error:
                return Alert(
                    title: Text(errorMessage),
                    message: Text(errorDescription),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .captureSize(in: $containerSize)
        .environmentObject(store) // crashes without it. bug in Swift UI?
    }
    
    
    var grid: some View {
        CollectionView(cells, id: \.self) { cell  in
            switch cell {
            case .sticker(let sticker):
                Button {
                    presentedStickerID = (stickerSet.id, sticker.id)
                } label: {
                    StickerView(sticker: sticker)
                        .frame(width: cellSize, height: cellSize)
                }
            case .newSticker:
                addImage
                    .frame(width: cellSize, height: cellSize)
                    .dragItems([])
            }
            
        }
        .onMove { from, to in
            guard from.allSatisfy({ $0 < stickerSet.stickers.endIndex }) else { return }
            stickerSet.stickers.move(fromOffsets: from, toOffset: min(to, stickerSet.stickers.endIndex))
        }
        .collectionViewLayout(FlowCollectionViewLayout(minimumLineSpacing: spacing, minimumInteritemSpacing: spacing))
        .height(max(collectionViewHeight, cellSize))
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
            do {
                try store.export(stickerSet)
            } catch let error as StickerImport.StickersError {
                switch error {
                case .fileTooBig:
                    errorMessage = "File Too Big"
                    errorDescription = "One of the sticker files is too big" // TODO: not good enough
                case .invalidDimensions:
                    errorMessage = "Wrong Dimensions"
                    errorDescription = "One of the stickers has wrong dimensions"
                case .countLimitExceeded:
                    errorMessage = "Too Many Stickers"
                    errorDescription = "Maximum of 120 stickers is allowed"
                case .dataTypeMismatch:
                    errorMessage = "Wrong Type"
                    errorDescription = "Sticker's type doesn't match set's type" // ???
                case .setIsEmpty:
                    errorMessage = "Empty set"
                    errorDescription = "Looks like this set does not contain any stickers"
                case .telegramNotInstalled:
                    errorMessage = "Telegram Not Installed"
                    errorDescription = "Could not send stickers to Telegram. Telegram app is probably not installed."
                }
                alertContent = .error
                alertPresented = true
            } catch {
                alertContent = .error
                alertPresented = true // unknown error
            }
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
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
}


struct StickerView: View {
    
    var sticker: Sticker
    
    @EnvironmentObject var store: Store
    
    
    var body: some View {
        ZStack {
            Color.secondary.opacity(0.08)
                .cornerRadius(12)
            if let image = store.image(for: sticker.id) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(6)
            }
        }
        .overlay(Group {
            if let emoji = store.getSticker(id: sticker.id)?.emoji, emoji.count > 0 {
                Text(emoji.prefix(3)) // improve?
                    .padding(8)
            }
        }, alignment: .bottomTrailing)
        .aspectRatio(1, contentMode: .fit)
    }
}


// MARK: - Actions

extension StickerSetEditor {
    
    func loadImage() {
        guard !loadedImagesData.isEmpty else { return }
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
        StickerSetEditor(stickerSet: .constant(Store.default().stickerSets.first!), isNew: true)
            .environmentObject(Store.default())
    }
}
