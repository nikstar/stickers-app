
import UIKit
import Vision

public final class RemoveBackgroundEffect {
    
    private var inputImage: UIImage
    private var outputImage: UIImage?
    private var monochromeBackground: Bool
    private var addBorder: Bool
    
    private init(inputImage: UIImage, monochromeBackground: Bool, addBorder: Bool) {
        self.inputImage = inputImage
        self.monochromeBackground = monochromeBackground
        self.addBorder = addBorder
    }
    
    public static func apply(to image: UIImage, monochromeBackground: Bool, addBorder: Bool) -> UIImage {
        let effect = RemoveBackgroundEffect(inputImage: image, monochromeBackground: monochromeBackground, addBorder: addBorder)
        return effect.removeBackground()
    }
    
    private func removeBackground() -> UIImage {
        let mask = getMask()
//        return mask
        var result = applyMask(mask)
        if addBorder {
           result = _addBorder(baseImage: result, maskImage: mask)
        }
        return result
    }
    
    
    func getMask() -> UIImage {
        do {
            if monochromeBackground {
//                let backgroundColor = UIColor.white
                
                let original = CIImage(cgImage: inputImage.cgImage!)
                
                let filter = ColorFilter()
                filter.inputImage = original
                filter.inputColor = .white
                
                let mask = filter.outputImage!
                
                if let cgImage = CIContext().createCGImage(mask, from: mask.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
            
            // try to be smart
            let configuration = MLModelConfiguration()
            let model = try VNCoreMLModel(for: DeepLabV3(configuration: configuration).model)
            
            let request = VNCoreMLRequest(model: model)
            request.imageCropAndScaleOption = .scaleFill // check this. fill works better?
            let handler = VNImageRequestHandler(cgImage: inputImage.cgImage!, options: [:])
            try handler.perform([request])
            
            if let results = request.results as? [VNCoreMLFeatureValueObservation],
                let segmentationMap = results.first?.featureValue.multiArrayValue {
                let segmentationMask = segmentationMap.image(min: 0, max: 1)
                return segmentationMask!.resizedImage(for: self.inputImage.size)!
            } else {
                print(request.results as Any)
                throw NSError(domain: "Wrong result type", code: 1, userInfo: nil) // TODO: fixme
            }
        } catch {
            return UIImage.imageFromColor(color: .black, size: inputImage.size, scale: inputImage.scale)!
        }
        
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


class ColorFilter: CIFilter {

    var inputImage: CIImage?
    var inputColor: CIColor?

    let kernel: CIColorKernel = {
        let kernelString = """
            kernel vec4 colorize(__sample pixel, vec4 color) {
                if ((abs(pixel.r-color.r) < 0.1) && (abs(pixel.g-color.g) < 0.1) && (abs(pixel.b-color.b) < 0.1)) {
                    pixel.rgb = vec3(0.0f, 0.0f, 0.0f);
                } else {
                    pixel.rgb = vec3(1.0f, 1.0f, 1.0f);
                }
                return pixel;
            }
            """
        return CIColorKernel(source: kernelString)!
    }()

    override var outputImage: CIImage? {

        guard let inputImage = inputImage else {
            print("\(self) cannot produce output because no input image provided.")
            return nil
        }
        guard let inputColor = inputColor else {
            print("\(self) cannot produce output because no input color provided.")
            return nil
        }

        let inputs = [inputImage, inputColor] as [Any]
        return kernel.apply(extent: inputImage.extent, arguments: inputs)
    }
}


