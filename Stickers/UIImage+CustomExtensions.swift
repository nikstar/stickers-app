//
//  UIImage+Extensions.swift
//  CoreMLBackgroundChangeSwiftUI
//
//  Created by Anupam Chugh on 27/05/21.
//

import Foundation
import UIKit

extension UIImage {
    class func imageFromColor(color: UIColor, size: CGSize=CGSize(width: 1, height: 1), scale: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func resizedImage(for size: CGSize) -> UIImage? {
            let image = self.cgImage
            let context = CGContext(data: nil,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: image!.bitsPerComponent,
                                    bytesPerRow: Int(size.width),
                                    space: image?.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                    bitmapInfo: image!.bitmapInfo.rawValue)
            context?.interpolationQuality = .high
            context?.draw(image!, in: CGRect(origin: .zero, size: size))

            guard let scaledImage = context?.makeImage() else { return nil }

            return UIImage(cgImage: scaledImage)
    }
    

}



extension UIImage {
  func withAlphaComponent(_ alpha: CGFloat) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    defer { UIGraphicsEndImageContext() }

    draw(at: .zero, blendMode: .normal, alpha: alpha)
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}

