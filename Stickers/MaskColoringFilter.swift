

import UIKit
import CoreImage


final class MaskColoringFilter: CIFilter {
    
    var inputImage: CIImage?
    var inputColor: CIColor?
    
    let kernel: CIColorKernel = {
        let kernelString = """
            kernel vec4 colorize(__sample pixel, vec4 color) {
                if ( all( equal( pixel, vec4(1.0f, 1.0f, 1.0f, 1.0f) ) ) ) {
                    pixel.rgba = color;
                } else {
                    pixel.rgba = vec4(0.0f, 0.0f, 0.0f, 0.0f);
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
