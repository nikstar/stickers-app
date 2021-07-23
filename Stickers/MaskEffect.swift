
import UIKit
import Vision

public final class MaskEffect {
    
    private var inputImage: UIImage
    private var outputImage: UIImage?
    private var config: MaskConfig
    
    private init(inputImage: UIImage, config: MaskConfig) {
        self.inputImage = inputImage
        self.config = config
    }
    
    static func apply(to image: UIImage, config: MaskConfig) -> UIImage {
        assert(image.scale == 1)
        let effect = MaskEffect(inputImage: image, config: config)
        return effect.getMask()
    }
    
    func getMask() -> UIImage {
        switch config {
        case .none:
            return emptyMask()
        case .autoremove:
            return getAutoMask()
        case .monochromeOnly:
            return getMonochromeMask()
        case .custom:
            assertionFailure()
            return UIImage.imageFromColor(color: .black, size: inputImage.size, scale: 1)!
        }
    }
    
    func getAutoMask() -> UIImage {
        do {
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
            return emptyMask()
        }
    }
    
    func getMonochromeMask() -> UIImage {
        let original = CIImage(cgImage: inputImage.cgImage!)
        
        let filter = MonochromeColorFilter()
        filter.inputImage = original
        filter.inputColor = .white
        
        let mask = filter.outputImage!
        
        if let cgImage = CIContext().createCGImage(mask, from: mask.extent) {
            return UIImage(cgImage: cgImage)
        }
        return emptyMask()
    }
    
    func emptyMask() -> UIImage {
        UIImage.imageFromColor(color: .black, size: inputImage.size, scale: inputImage.scale)!
    }
}


class MonochromeColorFilter: CIFilter {

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


