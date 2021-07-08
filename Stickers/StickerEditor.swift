//
//  StickerEditor.swift
//  Stickers
//
//  Created by  nikstar on 28.06.2021.
//

import SwiftUI

struct StickerEditor: View {
    
    @Binding var sticker: Sticker
    
    @State var previewSize: CGSize = CGSize(width: 100, height: 100)
    @State var deleteAlertPresented = false

    @EnvironmentObject var store: Store
    @Environment(\.presentationMode) var presentationMode
    
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
        ZStack {
            Color.clear
            StickerViewLarge(sticker: sticker, size: previewSize.height - 36 - 26, showEmoji: false)
                // .border(Color.blue)
                .padding(.top, 36)
                .padding(.bottom, 26)
                .padding(.horizontal, 24)
                // .border(Color.red)
        }
        .aspectRatio(1.5, contentMode: .fit)
        .background(backgroundPattern)
        .captureSize(in: $previewSize)
        // .border(Color.red)
    }
    
    var backgroundPattern: some View {
        Checkerboard(rows: 16, columns: 24)
            .fill(Color.secondary.opacity(0.10))
            .background(Color.secondary.opacity(0.06))
    }
    
    var editOptions: some View {
        NavigationView {
            List {
                emojiOptions
                
                if sticker.type != .animated {
                    Section(header: Text("Background")) {
                        Toggle("Remove background", isOn: $sticker.background.removeBackground.animation())
                        if sticker.background.removeBackground {
                            Toggle("Just remove white background", isOn: $sticker.background.monochromeBackground)
                            Toggle("Add white border", isOn: $sticker.background.addBorder)
                        }
                    }
                    
                    Section(header: Text("Text"), footer: EmptyView()) {
                        TextField("Text", text: $sticker.foreground.text)
                            .keyboardDismissMode(.interactive)
                        Picker("Position", selection: $sticker.foreground.position) {
                            ForEach(Sticker.TextPosition.allCases, id: \.self) { position in
                                Text(position.rawValue.capitalized).tag(position)
                            }
                        }
                        Picker("Font", selection: $sticker.foreground.font) {
                            ForEach(Sticker.TextFont.allCases, id: \.self) { font in
                                Text(font.description).tag(font)
                            }
                        }
                        Picker("Color", selection: $sticker.foreground.color) {
                            ForEach(Sticker.TextColor.allCases, id: \.self) { color in
                                Text(color.description).tag(color) // Not localized
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
    var emojiOptions: some View {
        Section(header: Text("Emoji"), footer: Text("Sticker will be suggested when user types these emoji. At least one is required by Telegram.")) {
            TextField("Emoji", text: $sticker.emoji, onEditingChanged: { isEditing in
                sticker.emoji = sticker.emoji.filter { $0.isEmoji }
                sticker.emoji.removeRepeatingCharacters()
            }, onCommit: {
                sticker.emoji = sticker.emoji.filter { $0.isEmoji }
                sticker.emoji.removeRepeatingCharacters()
            })
            .keyboardDismissMode(.interactive)
            .overlay(
                SmallButton(text: "Random", color: Color.blue, action: {
                    sticker.emoji = String(Character.randomEmoji())
                })
                .padding(.trailing, -10)
                , alignment: .trailing)
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
    
    static var emojis: [Character] = "😀😃😄😁😆😅😂🤣🥲☺️😊😇🙂🙃😉😌😍🥰😘😗😙😚😋😛😝😜🤪🤨🧐🤓😎😏🥸🤩🥳😒😞😟😕🙁☹️😣😖😫😩🥺😢😠😡🤬🤯😳🥵🥶😶‍🌫️😱😨😰😥😓🤗🤔🤭🤫🤥😐😑😬🙄😯😦😧😮🥱😴🤤😪😮‍💨😵😵‍💫🤐🥴🤢🤮🤧😷🤒🤕🤑🤠😈👿🤲👐🙌👏✌️🤟🤘👌🤌🖐🖖💪".map { $0 }
    
    var isEmoji: Bool {
        guard let first = unicodeScalars.first else { return false }
        return first.properties.isEmoji && ( unicodeScalars.count > 1 || first.properties.isEmojiPresentation)
    }
    
    static func randomEmoji() -> Character {
        return emojis.randomElement()!
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


extension Sticker.TextFont {
    var description: String {
        switch self {
        case .arial:
            return "Arial"
        case .comicSans:
            return "Comic Sans"
        case .helvetica:
            return "Helvetica"
        case .impact:
            return "Impact"
        case .snellRoundhand:
            return "Fancy"
        }
    }
}


extension Sticker.TextColor {
    var description: String {
        switch self {
        case .white:
            return "White"
        case .whiteWithBorder:
            return  "White with black border"
        case .black:
            return "Black"
        case .blackWithBorder:
            return "Black with white border"
        case .yellow:
            return "Yellow"
        case .orange:
            return "Orange"
        case .blue:
            return "Blue"
        }
    }
}
