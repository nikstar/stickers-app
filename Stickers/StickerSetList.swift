//
//  ContentView.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import SwiftUI


struct StickerSetList: View {
    
    @EnvironmentObject var store: Store
    
    @State var isPresented: Bool = false
    @State var presentedStickerSetID: UUID? = nil
    
    var body: some View {
        ScrollView {
            List(store.stickerSets) { stickerSet in
//                Button {
//                    presentedStickerSetID = stickerSet.id
//                    isPresented = true
//                } label: {
                    StickerRow(stickerSet: stickerSet)
//                }
            }
//            .sheet(isPresented: $isPresented, onDismiss: {}) {
//                if let id = presentedStickerSetID {
//                    StickerSetEditor(stickerSet: store.binding(for: id), isPresented: $isPresented)
//                } else {
//                    EmptyView() // check this is not reachable
//                }
//            }
        }
        

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StickerSetList().environmentObject(Store.testDefault)
    }
}
