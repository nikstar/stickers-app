/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The content of the scroll view. Adds some margin and a shadow. Setting the documentView places this view, and sizes it to the canvasSize.
*/

import UIKit

class CanvasContainerView: UIView {
    let canvasSize: CGSize
    
    let canvasView: UIView
    
    var documentView: UIView? {
        willSet {
            if let previousView = documentView {
                previousView.removeFromSuperview()
            }
        }
        didSet {
            if let newView = documentView {
                newView.frame = canvasView.bounds
                canvasView.addSubview(newView)
            }
        }
    }
    
    required init(canvasSize: CGSize) {
        let screenBounds = UIScreen.main.bounds
        let minDimension = max(screenBounds.width, screenBounds.height)
        self.canvasSize = canvasSize

        var size = canvasSize
        size.width = max(minDimension, size.width)
        size.height = max(minDimension, size.height)
        
        let frame = CGRect(origin: .zero, size: size)
        
        let canvasOrigin = CGPoint(x: (frame.width - canvasSize.width) / 2.0, y: (frame.height - canvasSize.height) / 2.0)
        let canvasFrame = CGRect(origin: canvasOrigin, size: canvasSize)
        canvasView = UIView(frame: canvasFrame).with {
            $0.backgroundColor = UIColor.tertiarySystemBackground
            $0.layer.borderWidth = 1.0
            $0.layer.borderColor = UIColor.separator.cgColor
        }
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.systemBackground
        self.addSubview(canvasView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
