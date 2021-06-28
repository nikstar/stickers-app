//
//  ContentView.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import SwiftUI


struct StickerSetList: View {
    
    @EnvironmentObject var store: Store
    
    /// Second element means new or not
    @State var presentedStickerSetID: (UUID, Bool)?  = nil
    @State var isPresented: Bool = false
    
    var newStickerSet: some View {
        Button {
            presentedStickerSetID = (UUID(), true)
        } label: {
            Text("New Sticker Set")
                .font(.title.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 66, maxHeight: 66, alignment: .center)
                .background(
                    gradient1
                        .cornerRadius(24, antialiased: true)
                )
                .padding(.horizontal, 8)
        }
        .padding(.top, 22)
        .padding(.bottom, 10)
    }
    
    var body: some View {
        ScrollView {
            newStickerSet
            
            VStack(alignment: .center, spacing: 10) {
                ForEach(store.stickerSets) { stickerSet in
                    Button {
                        presentedStickerSetID = (stickerSet.id, false)
                    } label: {
                        StickerRow(stickerSet: stickerSet)
                    }
                }
        
            }
        }
        .onChange(of: presentedStickerSetID?.0) { id in
            if !isPresented && id != nil {
                isPresented = true
            }
        }
        .sheet(isPresented: $isPresented, onDismiss: {
            let id = presentedStickerSetID?.0
            let shouldDelete = store.stickerSets.first(where: { $0.id == id })?.stickers.isEmpty ?? false
            presentedStickerSetID = nil
            if shouldDelete {
                store.stickerSets.removeAll(where: { $0.id == id })
            }
        }) {
            if let id = presentedStickerSetID {
                StickerSetEditor(stickerSet: store.binding(forStickerSet: id.0), isNew: id.1, isPresented: $isPresented)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StickerSetList().environmentObject(Store.testDefault)
    }
}
