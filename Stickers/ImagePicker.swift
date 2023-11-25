//
//  ImagePicker.swift
//  Stickers
//
//  Created by  nikstar on 27.06.2021.
//

import SwiftUI
import PhotosUI
import TelegramStickersImport

struct ImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var loadedImagesData: [Data]
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.preferredAssetRepresentationMode = .compatible
        configuration.selectionLimit = 120 // TODO: make this accurate
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
}


// MARK: - Coordinaror



fileprivate func loadImages(_ imageProxies: [PHPickerResult]) async -> [Data] {
    
    return await withTaskGroup(of: (Int, Data?).self, returning: [Data].self) { group in
        for (index, imageProxy) in imageProxies.enumerated() {
            group.addTask {
                let data = await loadOneImage(imageProxy: imageProxy)
                return (index, data)
            }
        }
        var enumeratedImages: [(Int, Data?)] = []
        for await pair in group {
            enumeratedImages.append(pair)
        }
        return enumeratedImages
            .sorted(by: { lhs, rhs in lhs.0 < rhs.0 })
            .compactMap({ pair in pair.1 })
    }
}


fileprivate func loadOneImage(imageProxy: PHPickerResult) async -> Data? {
    return await withCheckedContinuation { (continuation: CheckedContinuation<Data?, Never>) in
        imageProxy.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { (url, error) in
            
            guard let url else {
                continuation.resume(returning: nil); return
            }
            
            let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else {
                continuation.resume(returning: nil); return
            }
            
            let downsampleOptions = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: 1_024,
            ] as CFDictionary
            
            guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions) else {
                continuation.resume(returning: nil); return
            }
            
            let data = NSMutableData()
            
            guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil) else {
                continuation.resume(returning: nil); return
            }
            
            // Don't compress PNGs, they're too pretty
            let isPNG: Bool = {
                guard let utType = cgImage.utType else { return false }
                return (utType as String) == UTType.png.identifier
            }()
            
            let destinationProperties = [
                kCGImageDestinationLossyCompressionQuality: isPNG ? 1.0 : 0.75
            ] as CFDictionary
            
            CGImageDestinationAddImage(imageDestination, cgImage, destinationProperties)
            CGImageDestinationFinalize(imageDestination)
            
            continuation.resume(returning: Data(data))
        }
    }
}

extension ImagePicker {
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        let parent: ImagePicker
        private var task: Task<Void, Never>? = nil
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            task = Task {
                let loaded = await loadImages(results)
                parent.loadedImagesData = loaded
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
}

//
//struct ImagePicker_Previews: PreviewProvider {
//    static var previews: some View {
//        ImagePicker(loadedImagesData: .constant([]))
//    }
//}
