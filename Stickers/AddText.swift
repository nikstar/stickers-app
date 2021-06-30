//
//  AddText.swift
//  Stickers
//
//  Created by  nikstar on 29.06.2021.
//

import UIKit


final class AddText {
    
    var image: UIImage
    let text: String
    let position: Sticker.TextPosition
    let font: Sticker.TextFont
    
    init(image: UIImage, text: String, position: Sticker.TextPosition, font: Sticker.TextFont) {
        self.image = image
        self.text = text
        self.position = position
        self.font = font
    }
    
    static func apply(to image: UIImage, text: String, position: Sticker.TextPosition, font: Sticker.TextFont) -> UIImage {
        let addText = AddText(image: image, text: text, position: position, font: font)
        return addText.addText()
    }
    
    func addText() -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        let originY: CGFloat
        switch position {
        case .top:
            originY = 0
        case .middle:
            originY = 0.33 * image.size.height
        case .bottom:
            originY = 0.67 * image.size.height
        }
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        let font: UIFont
        switch self.font {
        case .arial:
            font = UIFont(name: "Helvetica-Bold", size: 80)! // lol
        case .impact:
            font = UIFont(name: "Helvetica-Bold", size: 80)! // exists? no :(
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key:Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.white,
            .strokeColor: UIColor.black,
            .strokeWidth: -8.0,
        ]
        let textY = originY + (image.size.height/3 - font.lineHeight) / 2
        text.draw(in: CGRect(x: 0, y: textY, width: image.size.width, height: image.size.height - textY).integral, withAttributes: attributes)
        let result = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return result
    }
    
}
