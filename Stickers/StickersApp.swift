//
//  StickersApp.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import SwiftUI


@main
struct StickersApp: App {
    
    @StateObject var store = Store.default()

    var body: some Scene {
        WindowGroup {
//            StickerSetList()
            MaskEditor(sticker: store.stickers.first!, mask: UIImage())
                .environmentObject(store)
        }
    }
}


struct Wrapper: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> CanvasMainViewController {
        return CanvasMainViewController()
    }
    
    
    func updateUIViewController(_ uiViewController: CanvasMainViewController, context: Context) {
        
    }
}
