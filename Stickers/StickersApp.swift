//
//  StickersApp.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import SwiftUI

let store = Store.default()

@main
struct StickersApp: App {
    var body: some Scene {
        WindowGroup {
            StickerSetList()
                .environmentObject(store)
        }
    }
}
