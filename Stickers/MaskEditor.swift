//
//  MaskEditor.swift
//  Stickers
//
//  Created by  nikstar on 23.07.2021.
//

import SwiftUI
import UIKit


struct MaskEditor: View {
    
    var sticker: Sticker
    
    @State var scaleValue: CGFloat = 1
    @State var lastScaleValue: CGFloat = 1.0
    @GestureState var magnifyBy: CGFloat = 1.0

    @EnvironmentObject var store: Store

    private var image: UIImage? {
        store.getOriginalImage(sticker: sticker.id)
    }
    private var mask: UIImage {
        store.getMask(sticker: sticker.id)
    }
    
    var body: some View {
        Group {
            if let image = image {
                VStack(spacing: 0) {
                    CanvasView(image: image, mask: mask) { newMask in print(newMask) }
                    Rectangle()
                        .foregroundColor(Color(UIColor.secondarySystemBackground))
                        .frame(height: 200)
                }
            } else {
                ErrorView()
            }
        }
    }
}


// MARK: - Preview

struct MaskEditor_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store.default()
        return MaskEditor(sticker: store.stickers.first!)
                        .environmentObject(store)
        
    }
}
