
import UIKit
import Vision

public final class RemoveBackgroundEffect {
    
    private var inputImage: UIImage
    private var outputImage: UIImage?
    private var addBorder: Bool
    
    private init(inputImage: UIImage, addBorder: Bool) {
        self.inputImage = inputImage
        self.addBorder = addBorder
    }
    
    public static func apply(to image: UIImage, addBorder: Bool) -> UIImage {
        let effect = RemoveBackgroundEffect(inputImage: image, addBorder: addBorder)
        return effect.removeBackground()
    }
    
    private func removeBackground() -> UIImage {
        do {
            let configuration = MLModelConfiguration()
            let model = try VNCoreMLModel(for: DeepLabV3(configuration: configuration).model)
            
            let request = VNCoreMLRequest(model: model)
            request.imageCropAndScaleOption = .scaleFill // check this. fill works better?
            let handler = VNImageRequestHandler(cgImage: inputImage.cgImage!, options: [:])
            try handler.perform([request])
            
            if let results = request.results as? [VNCoreMLFeatureValueObservation],
                let segmentationMap = results.first?.featureValue.multiArrayValue {
                let segmentationMask = segmentationMap.image(min: 0, max: 1)
                let maskImage = segmentationMask!.resizedImage(for: self.inputImage.size)!
                var masked = applyMask(maskImage)
                
                if addBorder {
                    masked = _addBorder(baseImage: masked, maskImage: maskImage)
                }
                
                return masked
                
            } else {
                print(request.results as Any)
                
            }
        } catch {
            print(error)
        }
        return inputImage
    }
    
    func applyMask(_ maskImage: UIImage) -> UIImage {
        
        let backgroundImage = UIImage.imageFromColor(color: .clear, size: inputImage.size, scale: inputImage.scale)!

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
    
    func _addBorder(baseImage: UIImage, maskImage: UIImage) -> UIImage {
        
        let base = CIImage(cgImage: baseImage.cgImage!)
        let mask = CIImage(cgImage: maskImage.cgImage!)
        
        let edges = mask.applyingFilter("CIEdges", parameters: [
            kCIInputIntensityKey: 1.0
        ])
        
        let borderWidth = 0.02 * min(baseImage.size.width, baseImage.size.height)
        let wideEdges = edges.applyingFilter("CIMorphologyMaximum", parameters: [
            kCIInputRadiusKey: borderWidth
        ])
        
        let background = wideEdges.applyingFilter("CIMaskToAlpha")
        
        let composited = base.composited(over: background)
        
        let context = CIContext(options: nil)
        let cgImageRef = context.createCGImage(composited, from: composited.extent)!
        return UIImage(cgImage: cgImageRef)
    }
}
