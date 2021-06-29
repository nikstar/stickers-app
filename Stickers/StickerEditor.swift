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
                    backgroundPattern
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(16)
                    if !sticker.modifiedImageCached {
                        ProgressView()
                    }
                    
                }
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, 44)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
            }
        }
    }
    
    var backgroundPattern: some View {
        Checkerboard(rows: 16, columns: 16)
            .fill(Color.secondary.opacity(0.10))
            .background(Color.secondary.opacity(0.06))
            .cornerRadius(30)
    }
    
    var editOptions: some View {
        List {
            Section(header: Text("Emoji"), footer: Text("Sticker can be asociated with an emoji")) {
                TextField("Emoji", text: $sticker.emoji, onEditingChanged: { isEditing in
                    print("Editing changed: \(isEditing)")
                    sticker.emoji = sticker.emoji.filter { $0.isEmoji }
                }, onCommit: {
                    sticker.emoji = sticker.emoji.filter { $0.isEmoji }
                })
                
            }
            
            Section(header: Text("Background")) {
                Toggle("Remove background", isOn: $sticker.removeBackground.animation())
                if sticker.removeBackground {
                    Toggle("Add white border", isOn: $sticker.addBorder)
                }
            }
            Text("Hello")
        }
        .background(Color.orange)
        .listStyle(GroupedListStyle())
    }
}



struct StickerEditor_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store.default()
        let sticker = store.stickerSets[0].stickers[0]
        let binding = store.binding(forSticker: sticker)
        return StickerEditor(sticker: binding)
            .environmentObject(store)
            
    }
}


extension Character {
    var isEmoji: Bool {
        guard let first = unicodeScalars.first else { return false }
        print(self, first.properties.isEmoji && ( unicodeScalars.count > 1 || first.properties.isEmojiPresentation))
        return first.properties.isEmoji && ( unicodeScalars.count > 1 || first.properties.isEmojiPresentation)
    }
}
