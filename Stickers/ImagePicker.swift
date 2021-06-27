//
//  ImagePicker.swift
//  Stickers
//
//  Created by  nikstar on 27.06.2021.
//

import SwiftUI
import PhotosUI
import StickerImport

struct ImagePicker: UIViewControllerRepresentable {
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        let parent: ImagePicker
        
        private var resultsCount: Int = -1
        private var totalConversionsCompleted = 0 {
            didSet {
                if totalConversionsCompleted == resultsCount {
                    parent.loadedImagesData = selectedImageDatas.compactMap { $0 }
                    parent.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        let queue = DispatchQueue(label: "me.nikstar.Stickers.load")
        var selectedImageDatas: [Data?] = []
        
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            resultsCount = results.count
            totalConversionsCompleted = 0
            selectedImageDatas = [Data?](repeating: nil, count: results.count) // Awkwardly named, sure
            
            for (index, result) in results.enumerated() {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [queue] (url, error) in
                    guard let url = url else {
                        queue.sync { self.totalConversionsCompleted += 1 }
                        return
                    }
                    let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
                    guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else {
                        queue.sync { self.totalConversionsCompleted += 1 }
                        return
                    }
                    let downsampleOptions = [
                        kCGImageSourceCreateThumbnailFromImageAlways: true,
                        kCGImageSourceCreateThumbnailWithTransform: true,
                        kCGImageSourceThumbnailMaxPixelSize: 1_024,
                    ] as CFDictionary

                    guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions) else {
                        queue.sync { self.totalConversionsCompleted += 1 }
                        return
                    }

                    let data = NSMutableData()
                    
                    guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil) else {
                        queue.sync { self.totalConversionsCompleted += 1 }
                        return
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
                    
                    queue.sync {
                        self.selectedImageDatas[index] = data as Data
                        self.totalConversionsCompleted += 1
                    }
                }
            }
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var loadedImagesData: [Data]
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.preferredAssetRepresentationMode = .compatible
        configuration.selectionLimit = StickerImport.Limits.stickerSetStickerMaxCount
        
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

struct ImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        ImagePicker(loadedImagesData: .constant([]))
    }
}
