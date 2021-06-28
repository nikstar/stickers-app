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
            StickerSetList()
                .environmentObject(store)
        }
    }
}
