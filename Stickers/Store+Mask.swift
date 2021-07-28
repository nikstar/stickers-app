

import UIKit

extension Store {
    
    func getMask(sticker: UUID) -> UIImage {
        let image = maskCache.get(id: sticker)
        return image
    }
    
}
