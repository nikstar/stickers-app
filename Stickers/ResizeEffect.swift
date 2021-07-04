
import UIKit

final class ResizeEffect {
    
    static func apply(to image: UIImage) -> UIImage {
        var image = image
        if image.scale != 1.0 {
            image = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .up)
        }
        
        let size: CGSize
        if image.size.width >= image.size.height {
            size = CGSize(width: Int(512), height: Int(image.size.height / image.size.width * 512.0))
        } else {
            size = CGSize(width: Int(image.size.width / image.size.height * 512.0), height: Int(512))
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        image = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return image
    }
}
