
import SwiftUI
import UIKit


struct CanvasView: UIViewControllerRepresentable {
    
    var image: UIImage
    var mask: UIImage
    var maskUpdated: (UIImage) -> ()
    
    func makeCoordinator() -> CanvasViewCoordinator {
        CanvasViewCoordinator(self)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return CanvasViewController(image: image, mask: mask, coordinator: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}


// MARK: -

final class CanvasViewCoordinator {
    var wrapper: CanvasView
    
    init(_ wrapper: CanvasView) {
        self.wrapper = wrapper
    }
}


// MARK: -

final class CanvasViewController: UIViewController {
    
    var image: UIImage
    var mask: UIImage
    var coordinator: CanvasViewCoordinator
    
    private var scrollView = UIScrollView()
    private var backdropView = UIView()
    private var canvasView = UIView()
    private var imageView = UIImageView()
    private var maskView: StrokeCGView?
    
    private var strokeGestureRecognizer: StrokeGestureRecognizer?
    private var strokeCollection = StrokeCollection()

    
    // MARK: -
    
    init(image: UIImage, mask: UIImage, coordinator: CanvasViewCoordinator) {
        self.image = image
        self.mask = mask
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: -
    
    override func viewDidLoad() {
        
        let zoomToFit = min(UIScreen.main.bounds.width / image.size.width, UIScreen.main.bounds.height / image.size.height)
        let backdropSize = max(512, UIScreen.main.bounds.width, UIScreen.main.bounds.height, image.size.width, image.size.height) / zoomToFit
        
        scrollView.with {
            view.addSubview($0)
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
            $0.frame.size = CGSize(width: backdropSize, height: backdropSize)
            
            scrollView.addSubview($0)
        }
    
        canvasView.with {
            $0.frame.size = image.size
            
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.separator.cgColor
            
            backdropView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: backdropView.centerXAnchor).isActive = true
            $0.centerYAnchor.constraint(equalTo: backdropView.centerYAnchor).isActive = true
        }
        
        imageView.with {
            $0.image = image
//            $0.image = UIImage.imageFromColor(color: UIColor.systemPink, size: image.size, scale: image.scale)
            
            canvasView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: canvasView.topAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor).isActive = true
        }
        
        maskView = StrokeCGView(baseMaskImage: mask, frame: canvasView.frame).with {
            $0.backgroundColor = .white.withAlphaComponent(0.4)
            $0.layer.opacity = 0.4
            let filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 20])!
            $0.layer.filters = [filter]
            
            canvasView.addSubview($0)
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
            let zoomToFit = min(UIScreen.main.bounds.width / image.size.width, UIScreen.main.bounds.height / image.size.height)
            scrollView.setZoomScale(zoomToFit * 1.1, animated: true)
        }
    }
    
    func centerCanvasView(animated: Bool) {
        let offset = CGPoint(x: (backdropView.frame.width - scrollView.bounds.width) / 2.0, y: (backdropView.frame.height - scrollView.bounds.height) / 2.0)
        scrollView.setContentOffset(offset, animated: animated)
        let zoomToFit = min(UIScreen.main.bounds.width / image.size.width, UIScreen.main.bounds.height / image.size.height)
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
        maskView?.setNeedsDisplay(for: stroke)
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
        maskView?.strokeCollection = strokeCollection
    }
}


// MARK: - Zoom

extension CanvasViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        backdropView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        var desiredScale = self.traitCollection.displayScale
        if scale >= 2.0 {
            desiredScale *= 2.0
        }
        
        if let existingScale = maskView?.contentScaleFactor, abs(desiredScale - existingScale) > 0.000_01 {
            maskView?.contentScaleFactor = desiredScale
            maskView?.setNeedsDisplay()
        }
    }
}


// MARK: - Preview

struct CanvasView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store.default()
        return MaskEditor(sticker: store.stickers.first!)
                        .environmentObject(store)
        
    }
}

