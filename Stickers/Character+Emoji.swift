

extension Character {
    
    static var emojis: [Character] = "๐๐๐๐๐๐๐๐คฃ๐ฅฒโบ๏ธ๐๐๐๐๐๐๐๐ฅฐ๐๐๐๐๐๐๐๐๐คช๐คจ๐ง๐ค๐๐๐ฅธ๐คฉ๐ฅณ๐๐๐๐๐โน๏ธ๐ฃ๐๐ซ๐ฉ๐ฅบ๐ข๐ ๐ก๐คฌ๐คฏ๐ณ๐ฅต๐ฅถ๐ถโ๐ซ๏ธ๐ฑ๐จ๐ฐ๐ฅ๐๐ค๐ค๐คญ๐คซ๐คฅ๐๐๐ฌ๐๐ฏ๐ฆ๐ง๐ฎ๐ฅฑ๐ด๐คค๐ช๐ฎโ๐จ๐ต๐ตโ๐ซ๐ค๐ฅด๐คข๐คฎ๐คง๐ท๐ค๐ค๐ค๐ค ๐๐ฟ๐คฒ๐๐๐โ๏ธ๐ค๐ค๐๐ค๐๐๐ช".map { $0 }
    
    var isEmoji: Bool {
        guard let first = unicodeScalars.first else { return false }
        return first.properties.isEmoji && ( unicodeScalars.count > 1 || first.properties.isEmojiPresentation)
    }
    
    static func randomEmoji() -> Character {
        return emojis.randomElement()!
    }
}

