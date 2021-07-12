//
//  Protocols.swift
//  Stickers
//
//  Created by  nikstar on 12.07.2021.
//

import SwiftUI


protocol Cyclable: CaseIterable, Hashable where Self.AllCases: RandomAccessCollection, Self.AllCases.Index == Int {
}

extension Cyclable {
    mutating func switchToNext() {
        var i = Self.allCases.firstIndex(of: self)! + 1
        if i == Self.allCases.count {
            i = 0
        }
        self = Self.allCases[i]
    }
}


protocol LocalizedDescription {
    var localizedDescription: LocalizedStringKey { get }
}

