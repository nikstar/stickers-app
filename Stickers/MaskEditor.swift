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
    var mask: UIImage
    
    @EnvironmentObject var store: Store
    
    var body: some View {
        ZStack {
            
            Color.orange
            
            CanvasView()
            
//            if let image = store.image(for: sticker.id) {
//                ZStack {
//                    Color.clear
//                    Image(uiImage: image)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                }
//            } else {
//                errorView
//            }
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


struct CanvasView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let content = CanvasContainerView(canvasSize: CGSize(width: 1000, height: 1000))
        content.backgroundColor = .blue
        scrollView.addSubview(content)
        content.layer.backgroundColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
    }
}

//struct MaskEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        MaskEditor()
//    }
//}
