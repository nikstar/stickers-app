//
//  BackgroundConfig.swift
//  Stickers
//
//  Created by  nikstar on 03.07.2021.
//

import Foundation

struct BackgroundConfig: Hashable {
    
    var removeBackground: Bool = false
    var monochromeBackground: Bool = false
    var backgroundMaskModified: Bool = false
    
    var addBorder: Bool = false
}


extension BackgroundConfig {
    
    var maskConfig: MaskConfig {
        if removeBackground == false { return .none }
        if backgroundMaskModified { return .custom }
        if monochromeBackground { return .monochromeOnly }
        return .autoremove
    }
}


extension BackgroundConfig: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            removeBackground: try container.decodeIfPresent(Bool.self, forKey: .removeBackground) ?? false,
            monochromeBackground: try container.decodeIfPresent(Bool.self, forKey: .monochromeBackground) ?? false,
            backgroundMaskModified: try container.decodeIfPresent(Bool.self, forKey: .backgroundMaskModified) ?? false,
            addBorder: try container.decodeIfPresent(Bool.self, forKey: .addBorder) ?? false
        )
    }
}

