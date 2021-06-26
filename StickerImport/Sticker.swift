import Foundation
import UIKit

/// A sticker
public final class Sticker: Identifiable, Codable {
    
    /// Underlying sticker data
    public enum StickerData {
        
        /// Static sticker PNG data
        case image(Data)
        
        /// Animated sticker TGS data
        case animation(Data)
    
        /// A Boolean value that determines whether the sticker data contains animation
        var isAnimated: Bool {
            switch self {
                case .image:
                    return false
                case .animation:
                    return true
            }
        }
        
        /// Mime-type of sticker data
        var mimeType: String {
            switch self {
                case .image:
                    return "image/png"
                case .animation:
                    return "application/x-tgsticker"
            }
        }
        
        /// Sticker data
        var data: Data {
            switch self {
                case let .image(data), let .animation(data):
                    return data
            }
        }
    }
    
    /// Unique identifier
    public let id: UUID
    
    /// The data of the sticker
    public let data: StickerData
    
    /// Associated emojis of the sticker
    public let emojis: [String]
    
    /**
        Initializes a new sticker with the provided data and associated emojis.

        - Parameters:
            - id: Unique identifier
            - data: Data of the sticker
            - emojis: Associated emojis of the sticker

        - Returns: A sticker.
        */
    public init(id: UUID = UUID(), data: StickerData, emojis: [String]) {
        self.id = id
        self.data = data
        self.emojis = emojis
    }
}


extension Sticker.StickerData: Codable {
    enum CodingKeys: CodingKey {
        case image
        case animation
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(CodingKeys.image) {
            let data = try container.decode(Data.self, forKey: CodingKeys.image)
            self = .image(data)
        } else {
            let data = try container.decode(Data.self, forKey: CodingKeys.animation)
            self = .animation(data)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .image(let data):
            try container.encode(data, forKey: .image)
        case .animation(let data):
            try container.encode(data, forKey: .animation)
        }
    }
    
}

extension Sticker {
    public var imageData: Data? {
        if case .image(let data) = data {
            return data
        }
        return nil
    }
}
