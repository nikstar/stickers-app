//
//  MaskEditor.swift
//  Stickers
//
//  Created by  nikstar on 23.07.2021.
//

import SwiftUI
import UIKit
import SwiftUIX

struct MaskEditor: View {
    
    var sticker: Sticker
    var mask: UIImage
    
    @State var scaleValue: CGFloat = 1
    @State var lastScaleValue: CGFloat = 1.0
    @GestureState var magnifyBy: CGFloat = 1.0

    @EnvironmentObject var store: Store

    private var image: UIImage? {
        store.image(for: sticker.id)
    }
    
    
    var body: some View {
        Group {
            if let image = image {
                VStack(spacing: 0) {
                    CanvasView(image: image)
                    Rectangle().foregroundColor(.secondarySystemBackground).height(200)
                }
            } else {
                ErrorView()
            }
        }
    }
}


struct CanvasView: UIViewControllerRepresentable {
    
    var image: UIImage
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return CanvasViewController().with {
            $0.image = image
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}


final class CanvasViewController: UIViewController {
    
    var image: UIImage?
    
    private var scrollView = UIScrollView()
    private var backdropView = UIView()
    private var canvasView = UIView()
    private var imageView = UIImageView()
    private var maskView = StrokeCGView()
    
    private var strokeGestureRecognizer: StrokeGestureRecognizer?
    private var strokeCollection = StrokeCollection()

    
    override func viewDidLoad() {
        
        view.addSubview(scrollView)
        scrollView.addSubview(backdropView)
        backdropView.addSubview(canvasView)
        canvasView.addSubview(imageView)
        canvasView.addSubview(maskView)
        
        let size = image?.size ?? CGSize(width: 512, height: 512)
        let zoomToFit = min(UIScreen.main.bounds.width / size.width, UIScreen.main.bounds.height / size.height)
        let backdropSize = max(512, UIScreen.main.bounds.width, UIScreen.main.bounds.height, image?.size.width ?? 0, image?.size.height ?? 0) / zoomToFit
        
        
        scrollView.with {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            $0.delegate = self
            $0.minimumZoomScale = max(0.5, zoomToFit * 0.95)
            $0.maximumZoomScale = 8
            $0.bouncesZoom = true
            
            $0.panGestureRecognizer.minimumNumberOfTouches = 2
        }
    
        backdropView.with {
            $0.backgroundColor = .blue
            $0.frame.size = CGSize(width: backdropSize, height: backdropSize)
        }
    
        canvasView.with {
            $0.frame.size = size
            
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.separator.cgColor
            
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: backdropView.centerXAnchor).isActive = true
            $0.centerYAnchor.constraint(equalTo: backdropView.centerYAnchor).isActive = true
        }
        
        imageView.with {
            $0.image = image
            
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: canvasView.topAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor).isActive = true
        }
        
        maskView.with {
            $0.backgroundColor = .white.withAlphaComponent(0.4)
            $0.layer.opacity = 0.5
            
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: canvasView.topAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor).isActive = true
        }
        
        setupStrokeGestureRecognizer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        centerCanvasView(animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            let size = image?.size ?? CGSize(width: 512, height: 512)
            let zoomToFit = min(UIScreen.main.bounds.width / size.width, UIScreen.main.bounds.height / size.height)
            scrollView.setZoomScale(zoomToFit * 1.1, animated: true)
        }
    }
    
    func centerCanvasView(animated: Bool) {
        let origin = CGPoint(x: (backdropView.frame.width - scrollView.bounds.width) / 2.0, y: (backdropView.frame.height - scrollView.bounds.height) / 2.0)
        let size = image?.size ?? CGSize(width: 512, height: 512)
        let zoomToFit = min(UIScreen.main.bounds.width / size.width, UIScreen.main.bounds.height / size.height)
        scrollView.setContentOffset(origin, animated: animated)
        scrollView.setZoomScale(zoomToFit, animated: animated)
    }
}


// MARK: - Gesture recognizer

extension CanvasViewController: UIGestureRecognizerDelegate {
    
    /// A helper method that creates stroke gesture recognizers.
    /// - Tag: setupStrokeGestureRecognizer
    func setupStrokeGestureRecognizer() {
        strokeGestureRecognizer = StrokeGestureRecognizer(target: self, action: #selector(strokeUpdated(_:))).with {
            $0.delegate = self
            $0.cancelsTouchesInView = false
            $0.coordinateSpaceView = maskView
            $0.isForPencil = false
        }
        scrollView.addGestureRecognizer(strokeGestureRecognizer!)
    }

    
    func receivedAllUpdatesForStroke(_ stroke: Stroke) {
        maskView.setNeedsDisplay(for: stroke)
        stroke.clearUpdateInfo()
    }

    /// Handles the gesture for `StrokeGestureRecognizer`.
    /// - Tag: strokeUpdate
    @objc func strokeUpdated(_ strokeGesture: StrokeGestureRecognizer) {
                
        if strokeGesture.state == .cancelled {
            strokeCollection.activeStroke = nil
            return
        }
        
        let stroke = strokeGesture.stroke
        if strokeGesture.state == .began ||
           (strokeGesture.state == .ended && strokeCollection.activeStroke == nil) {
            strokeCollection.activeStroke = stroke
        }
    
        if strokeGesture.state == .ended {
            strokeCollection.takeActiveStroke()
        }
        print(strokeCollection.strokes.count)
        maskView.strokeCollection = strokeCollection
    }
}


// MARK: - Zoom

extension CanvasViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        backdropView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        var desiredScale = self.traitCollection.displayScale
        let existingScale = maskView.contentScaleFactor
        
        if scale >= 2.0 {
            desiredScale *= 2.0
        }
        
        if abs(desiredScale - existingScale) > 0.000_01 {
            maskView.contentScaleFactor = desiredScale
            maskView.setNeedsDisplay()
        }
    }
}


// MARK: - Preview

struct MaskEditor_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store.default()
        return MaskEditor(sticker: store.stickers.first!, mask: UIImage())
                        .environmentObject(store)
        
    }
}
