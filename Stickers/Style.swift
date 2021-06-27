//
//  ButtonStyles.swift
//  Stickers
//
//  Created by  nikstar on 26.06.2021.
//

import SwiftUI

let gradient1 = LinearGradient(gradient: Gradient(colors: [
    Color(.sRGB, red: 0, green: 150.0/255, blue: 248.0/255, opacity: 1),
    Color(.sRGB, red: 212.0/255, green: 124.0/255, blue: 237.0/255, opacity: 1),
    Color(.sRGB, red: 1, green: 135.0/255, blue: 149.0/255, opacity: 1)
]), startPoint: .bottomLeading, endPoint: .topTrailing)


//struct ButtonStyles: View {
//    var body: some View {
//        Button {
//
//        } label: {
//            Text("New Sticker Set")
//        }
//        .buttonStyle(PrettyButtonStyle())
//
//    }
//}
//
//struct PrettyButtonStyle: ButtonStyle {
//
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//    }
//}
//
//struct ButtonStyles_Previews: PreviewProvider {
//    static var previews: some View {
//        ButtonStyles()
//    }
//}
