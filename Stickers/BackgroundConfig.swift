//
//  BackgroundConfig.swift
//  Stickers
//
//  Created by  nikstar on 03.07.2021.
//

import Foundation

struct BackgroundConfig: Codable, Equatable, Hashable {
    var removeBackground: Bool = false
    var monochromeBackground: Bool = false
    var addBorder: Bool = false
}

