//
//  StickerEditor.swift
//  Stickers
//
//  Created by  nikstar on 28.06.2021.
//

import SwiftUI

struct StickerEditor: View {
    
    
    @Binding var sticker: Sticker
    
    @EnvironmentObject var store: Store
    @Environment(\.presentationMode) var presentationMode

    @State var deleteAlertPresented = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            stickerPreview
                
            editOptions
                .shadow(radius: 10)
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
                title: Text("Delete sticker"),
                message: Text("Are you sure you want to delete this sticker? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    store.removeSticker(id: sticker.id)
                    
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    var stickerPreview: some View {
        Group {
            if let image = store.image(for: sticker.id) {
                ZStack {
                    Color.clear
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.top, 44)
                        .padding(.bottom, 40)
                        .padding(.horizontal, 24)
                    if !sticker.modifiedImageCached {
                        ProgressView()
                    }
                    
                }
                .aspectRatio(1.5, contentMode: .fit)
                .background(backgroundPattern)
            }
        }
    }
    
    var backgroundPattern: some View {
        Checkerboard(rows: 16, columns: 24)
            .fill(Color.secondary.opacity(0.10))
            .background(Color.secondary.opacity(0.06))
    }
    
    var editOptions: some View {
        NavigationView {
            List {
                Section(header: Text("Emoji"), footer: Text("Sticker can be asociated with an emoji")) {
                    TextField("Emoji", text: $sticker.emoji, onEditingChanged: { isEditing in
                        print("Editing changed: \(isEditing)")
                        sticker.emoji = sticker.emoji.filter { $0.isEmoji }
                        sticker.emoji.removeRepeatingCharacters()
                    }, onCommit: {
                        sticker.emoji = sticker.emoji.filter { $0.isEmoji }
                        sticker.emoji.removeRepeatingCharacters()
                    })
                }
                
                Section(header: Text("Background")) {
                    Toggle("Remove background", isOn: $sticker.removeBackground.animation())
                    if sticker.removeBackground {
                        Toggle("Add white border", isOn: $sticker.addBorder)
                    }
                }
                
                Section(header: Text("Text"), footer: EmptyView()) {
                    TextField("Text", text: $sticker.text)
                    Picker("Position", selection: $sticker.position) {
                        ForEach(Sticker.TextPosition.allCases, id: \.self) { position in
                            Text(position.rawValue.capitalized).tag(position)
                        }
                    }
                    Picker("Font", selection: $sticker.font) {
                        ForEach(Sticker.TextFont.allCases, id: \.self) { font in
                            Text(font.rawValue).tag(font) // Not localized
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
        
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


extension String {
    mutating func removeRepeatingCharacters() {
        var seen: Set<Character> = []
        self = String(self.filter { character in
            if !seen.contains(character) { seen.insert(character); return true }
            return false
        })
    }
}
