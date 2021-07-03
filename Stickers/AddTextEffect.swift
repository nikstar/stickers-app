//
//  AddText.swift
//  Stickers
//
//  Created by  nikstar on 29.06.2021.
//

import UIKit


final class AddTextEffect {
    
    var image: UIImage
    let text: String
    let position: Sticker.TextPosition
    let font: Sticker.TextFont
    let color: Sticker.TextColor
    
    init(image: UIImage, text: String, position: Sticker.TextPosition, font: Sticker.TextFont, color: Sticker.TextColor) {
        self.image = image
        self.text = text
        self.position = position
        self.font = font
        self.color = color
    }
    
    static func apply(to image: UIImage, text: String, position: Sticker.TextPosition, font: Sticker.TextFont, color: Sticker.TextColor) -> UIImage {
        let addText = AddTextEffect(image: image, text: text, position: position, font: font, color: color)
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
            font = UIFont(name: "Arial-BoldMT", size: 80)!  
        case .helvetica:
            font = UIFont(name: "Helvetica-Bold", size: 80)!
        case .impact:
            font = UIFont(name: "Impact", size: 80)!
        case .comicSans:
            font = UIFont(name: "ComicSansMS-Bold", size: 80)!
        case .snellRoundhand:
            font = UIFont(name: "SnellRoundhand-Black", size: 96)!
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        var attributes: [NSAttributedString.Key:Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
        ]
        switch color {
        case .white:
            attributes[.foregroundColor] = UIColor.white
        case .whiteWithBorder:
            attributes[.foregroundColor] = UIColor.white
            attributes[.strokeColor] = UIColor.black
            attributes[.strokeWidth] = -4.0
        case .black:
            attributes[.foregroundColor] = UIColor.black
        case .blackWithBorder:
            attributes[.foregroundColor] = UIColor.black
            attributes[.strokeColor] = UIColor.white
            attributes[.strokeWidth] = -4.0
        case .yellow:
            attributes[.foregroundColor] = UIColor.yellow
        case .orange:
            attributes[.foregroundColor] = UIColor.orange
        case .blue:
            attributes[.foregroundColor] = UIColor.blue
        }
        
        
        let textY = originY + (image.size.height/3 - font.lineHeight) / 2
        text.draw(in: CGRect(x: 0, y: textY, width: image.size.width, height: image.size.height - textY).integral, withAttributes: attributes)
        let result = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return result
    }
    
}
