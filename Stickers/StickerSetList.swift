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
    @State var presentedStickerSetID: (id: UUID, isNew: Bool)?  = nil
    @State var isPresented: Bool = false
    
    var body: some View {
        ScrollView {
            newStickerSet
                .padding(.bottom, 8)
            
            VStack(alignment: .center, spacing: 16) {
                ForEach(store.stickerSets) { stickerSet in
                    if !stickerSet.stickers.isEmpty {
                        Button {
                            presentedStickerSetID = (id: stickerSet.id, isNew: false)
                        } label: {
                            StickerSetRow(stickerSet: stickerSet)
                        }
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
            presentedStickerSetID = nil
            if let id = id {
                let shouldDelete = store.stickerSets.first(where: { $0.id == id })?.stickers.isEmpty ?? false
                if shouldDelete {
                    store.removeStickerSet(id: id)
                }
            }
        }) {
            if let id = presentedStickerSetID {
                StickerSetEditor(stickerSet: store.binding(forStickerSet: id.0), isNew: id.1).environmentObject(store)
            }
        }
    }
    
    var newStickerSet: some View {
        Button {
            presentedStickerSetID = (id: UUID(), isNew: true)
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
        .shadow(radius: 10)
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StickerSetList().environmentObject(Store.default())
    }
}
