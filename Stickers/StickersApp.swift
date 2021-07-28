
import SwiftUI


@main
struct StickersApp: App {
    
    @StateObject var store = Store.default()

    var body: some Scene {
        WindowGroup {
//            StickerSetList()
//            let id = store.stickerSets[0].stickers[0]
//            let sticker = store.getSticker(id: id)!
            let sticker = store.stickers[0]
            MaskEditor(sticker: sticker)
                .environmentObject(store)
        }
    }
}
