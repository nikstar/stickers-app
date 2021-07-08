//
//  SmallButton.swift
//  Stickers
//
//  Created by  nikstar on 01.07.2021.
//

import SwiftUI

struct SmallButton: View {
    
    var text: LocalizedStringKey
    var color: Color
    var action: () -> ()
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 120, style: .continuous))
                .padding(8)
        }
    }

}

struct SmallButton_Previews: PreviewProvider {
    static var previews: some View {
        SmallButton(text: "Done", color: .red, action: {})
            
    }
}
