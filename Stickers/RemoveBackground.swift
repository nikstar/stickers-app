
import UIKit
import Vision

public final class RemoveBackgroundEffect {
    
    private var inputImage: UIImage
    private var outputImage: UIImage?
    private var callback: (UIImage) -> ()
    
    private init(inputImage: UIImage, callback: @escaping (UIImage) -> () = { _ in }) {
        self.inputImage = inputImage
        self.callback = callback
    }
    
    public static func apply(to image: UIImage) -> UIImage {
        let effect = RemoveBackgroundEffect(inputImage: image)
        return effect.removeBackground()
    }
    
    private func removeBackground() -> UIImage {
        do {
            let configuration = MLModelConfiguration()
            let model = try VNCoreMLModel(for: DeepLabV3(configuration: configuration).model)
            
            let request = VNCoreMLRequest(model: model)
            request.imageCropAndScaleOption = .scaleFit // check this
            let handler = VNImageRequestHandler(cgImage: inputImage.cgImage!, options: [:])
            try handler.perform([request])
            
            if let results = request.results as? [VNCoreMLFeatureValueObservation],
                let segmentationMap = results.first?.featureValue.multiArrayValue {
                let segmentationMask = segmentationMap.image(min: 0, max: 1)
                let maskImage = segmentationMask!.resizedImage(for: self.inputImage.size)!
                return applyMask(maskImage)
                
            } else {
                print(request.results as Any)
                
            }
        } catch {
            print(error)
        }
        return inputImage
    }
    
    func applyMask(_ maskImage: UIImage) -> UIImage {
        
        let backgroundImage = UIImage.imageFromColor(color: .orange, size: inputImage.size, scale: inputImage.scale)!

        let original = CIImage(cgImage: inputImage.cgImage!)
        let background = CIImage(cgImage: backgroundImage.cgImage!)
        let mask = CIImage(cgImage: maskImage.cgImage!)
        
        let filter = CIFilter(name: "CIBlendWithMask", parameters: [
            kCIInputImageKey: original,
            kCIInputBackgroundImageKey: background,
            kCIInputMaskImageKey: mask
        ])
        if let compositeImage = filter?.outputImage {
            let context = CIContext(options: nil)
            let filteredImageRef = context.createCGImage(compositeImage, from: compositeImage.extent)!
            return UIImage(cgImage: filteredImageRef)
            
        }
        return inputImage
    }
}
