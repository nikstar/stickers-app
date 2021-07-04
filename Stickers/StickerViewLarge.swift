//
//  StickerView.swift
//  Stickers
//
//  Created by  nikstar on 03.07.2021.
//

import SwiftUI
import SwiftUIX
import Lottie


struct StickerViewLarge: View {
    
    var sticker: Sticker
    var size: CGFloat
    var showEmoji: Bool
    
    @EnvironmentObject var store: Store
    
    var body: some View {
        Group {
            switch sticker.type {
            case .image:
                imageView
            case .animated:
                animatedView
            }
        }
//        .aspectRatio(1, contentMode: .fit)
//        .frame(width: size, height: size, alignment: .center)
        .overlay(Group {
            if showEmoji, let emoji = store.getSticker(id: sticker.id)?.emoji, emoji.count > 0 {
                Text(emoji.prefix(3)) // improve?
                    .padding(2)
            }
        }, alignment: .bottomTrailing)
    }
    
    
    var imageView: some View {
        Group {
            if let image = store.image(for: sticker.id) {
                ZStack {
                    Color.clear
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            } else {
                errorView
            }
        }
    }
    
    var animatedView: some View {
        Group {
            if let animation = store.getAnimated(id: sticker.id) {
                LottieViewUI(animation: animation, size: size)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(CGSize(width: size, height: size))
            } else {
                errorView
            }
        }
    }
    
    var errorView: some View {
        Image(systemName: "nosign")
            .resizable()
            .foregroundColor(.tertiaryLabel)
            .aspectRatio(1, contentMode: .fit)
            .padding(10)
    }
}
