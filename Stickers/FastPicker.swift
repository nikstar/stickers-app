//
//  FastPicker.swift
//  Stickers
//
//  Created by  nikstar on 12.07.2021.
//

import SwiftUI


struct FastPicker<Item: Cyclable & LocalizedDescription, Label: View>: View {
    
    var item: Binding<Item>
    var label: () -> Label
    
    init(_ item: Binding<Item>, @ViewBuilder label: @escaping () -> Label) {
        self.item = item
        self.label = label
    }
    
    var body: some View {
        HStack {
            Button {
                item.wrappedValue.switchToNext()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .foregroundColor(.blue)
                    .background(Color.white.clipShape(Circle()).padding(3))
                label()
                    .foregroundColor(.primary)
                Spacer(minLength: 8)
                    .maxWidth(20)
            }
            .buttonStyle(BorderlessButtonStyle())
            
            Spacer(minLength: 0)
            
            Menu {
                ForEach(Item.allCases, id: \.self) { item in
                    Button { self.item.wrappedValue  = item } label: {
                        Text(item.localizedDescription)
                    }
                }
            } label: {
                Spacer()
                Text(item.wrappedValue.localizedDescription as LocalizedStringKey)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(3)
                    .padding(.leading, 8)
                    .padding(.trailing, 2)
                    .padding(.vertical, 6)
                    
            }
        }
        
    }
}

struct FastPicker_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                FastPicker(.constant(Sticker.TextFont.arial)) {
                    Text("Font")
                }
            }
            .listStyle(InsetListStyle())
        }
    }
}
