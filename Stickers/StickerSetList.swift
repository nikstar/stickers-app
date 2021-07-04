//
//  ContentView.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import SwiftUI
import SwiftUIX

struct StickerSetList: View {
    
    
    @State var presentedStickerSetID: (id: UUID, isNew: Bool)?  = nil
    @State var isPresented: Bool = false
    
    var rowHeight: CGFloat = 96 + 2 * 12 + 16 // preview height + 2 * padding + row spacing
    enum CellContent: Hashable {
        case stickerSet(StickerSet)
        case newSticker
    }
    var cells: [CellContent] { // this matters because StickerSet is Identifiable which screwes with collection view updating!
        store.stickerSets.map(CellContent.stickerSet)
    }
    
    @EnvironmentObject var store: Store
    
    var body: some View {
        ScrollView {
            newStickerSet
                .padding(.bottom, 8)
            
            CollectionView(cells, id: \.self) { row in
                if case .stickerSet(let stickerSet) = row, !stickerSet.stickers.isEmpty {
                    Button {
                        presentedStickerSetID = (id: stickerSet.id, isNew: false)
                    } label: {
                        StickerSetRow(stickerSet: stickerSet)
                    }
                    .maxWidth(.infinity)
                    .height(96 + 2 * 12)
                    // .border(Color.pink)
                }
            }
            .onMove { from, to in
                store.moveStickerSet(from: from, to: to)
            }
            .collectionViewLayout(FlowCollectionViewLayout(minimumLineSpacing: 16, minimumInteritemSpacing: 0))
            .height(max(rowHeight, rowHeight * CGFloat(store.stickerSets.count)))
            // .border(Color.orange)
        }
        .onChange(of: presentedStickerSetID?.0) { id in
            if !isPresented && id != nil {
                isPresented = true
            }
        }
        .sheet(isPresented: $isPresented, onDismiss: {
            presentedStickerSetID = nil
            store.removeEmptyStickerSets()
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
