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
    @State var emojiKeyboardVisible = false
    @State var maskEditorPresented = false

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
            backgroundPattern
            StickerViewLarge(sticker: sticker, size: previewSize.height - 36 - 26, showEmoji: false)
                .padding(.top, 36)
                .padding(.bottom, 26)
                .padding(.horizontal, 24)
        }
        .maxHeight(previewSize.width * 0.75)
        .captureSize(in: $previewSize)
    }
    
    var backgroundPattern: some View {
        Checkerboard(columns: 24)
            .fill(Color.secondary.opacity(0.10))
            .background(Color.secondary.opacity(0.06))
    }
    
    var editOptions: some View {
        NavigationView {
            List {
                emojiOptions
                
                if sticker.type != .animated {
                    
                    backgroundOptions
                    textOptions
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
    var emojiOptions: some View {
        Section(header: Text("Emoji"), footer: Text("Sticker will be suggested when user types these emoji. At least one is required by Telegram.")) {
            
            EmojiTextField(text: $sticker.emoji, isEditing: $emojiKeyboardVisible)
                .padding(.vertical, 2)
                .overlay(
                    Group {
                        if !emojiKeyboardVisible {
                            SmallButton(text: "Random", color: Color.blue, action: {
                                sticker.emoji = String(Character.randomEmoji())
                            })
                        } else {
                            SmallButton(text: "Done", color: Color.blue, action: {
                                    emojiKeyboardVisible = false
                            })
                        }
                    }
                    .padding(.trailing, -10),
                alignment: .trailing)
        }
    }
    
    var backgroundOptions: some View {
        Section(header: Text("Background")) {
            Toggle("Remove background", isOn: $sticker.background.removeBackground.animation())
            if sticker.background.removeBackground {
                Button("Edit background mask", action: { maskEditorPresented = true })
                Toggle("Just remove white background", isOn: $sticker.background.monochromeBackground)
                Toggle("Add white border", isOn: $sticker.background.addBorder)
            }
        }
        .sheet(isPresented: $maskEditorPresented, onDismiss: {}, content: {
            MaskEditor(sticker: sticker)
        })
    }
    
    var textOptions: some View {
        Section(header: Text("Text"), footer: EmptyView()) {
            
            TextField("Text", text: $sticker.foreground.text)
                .keyboardDismissMode(.interactive)
            FastPicker($sticker.foreground.position) {
                Text("Position")
            }
            FastPicker($sticker.foreground.font) {
                Text("Font")
            }
            FastPicker($sticker.foreground.color) {
                Text("Color")
            }
        }
    }
}


// MARK: - Preview

struct StickerEditor_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store.default()
        let sticker = store.stickerSets[0].stickers[0]
        let binding = store.binding(forSticker: sticker)
        return StickerEditor(sticker: binding)
            .environmentObject(store)
    }
}
