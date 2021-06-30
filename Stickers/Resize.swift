
import UIKit

final class Resize {
    
    static func apply(to image: UIImage) -> UIImage {
        
        let size: CGSize
        if image.size.width >= image.size.height {
            size = CGSize(width: 512, height: Int(image.size.height / image.size.width * 512))
        } else {
            size = CGSize(width: Int(image.size.width / image.size.height * 512), height: 512)
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
