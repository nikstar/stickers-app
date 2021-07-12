//
//  Character+Emoji.swift
//  Stickers
//
//  Created by  nikstar on 12.07.2021.
//

import Foundation


extension Character {
    
    static var emojis: [Character] = "😀😃😄😁😆😅😂🤣🥲☺️😊😇🙂🙃😉😌😍🥰😘😗😙😚😋😛😝😜🤪🤨🧐🤓😎😏🥸🤩🥳😒😞😟😕🙁☹️😣😖😫😩🥺😢😠😡🤬🤯😳🥵🥶😶‍🌫️😱😨😰😥😓🤗🤔🤭🤫🤥😐😑😬🙄😯😦😧😮🥱😴🤤😪😮‍💨😵😵‍💫🤐🥴🤢🤮🤧😷🤒🤕🤑🤠😈👿🤲👐🙌👏✌️🤟🤘👌🤌🖐🖖💪".map { $0 }
    
    var isEmoji: Bool {
        guard let first = unicodeScalars.first else { return false }
        return first.properties.isEmoji && ( unicodeScalars.count > 1 || first.properties.isEmojiPresentation)
    }
    
    static func randomEmoji() -> Character {
        return emojis.randomElement()!
    }
}
