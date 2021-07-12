//
//  EmojiTextField.swift
//  Stickers
//
//  Created by  nikstar on 12.07.2021.
//

import SwiftUI
import UIKit


class _EmojiTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override var textInputContextIdentifier: String? {
        return ""
    }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                self.keyboardType = .default // do not remove this
                return mode
            }
        }
        return nil
    }
}


struct EmojiTextField: UIViewRepresentable {
    
    @Binding var text: String
    @Binding var isEditing: Bool
    
    @State fileprivate var beganEditing: Date? = nil
    
    private let placeholder = NSLocalizedString("Emoji", comment: "")
    
    func makeUIView(context: Context) -> _EmojiTextField {
        let emojiTextField = _EmojiTextField()
        emojiTextField.placeholder = placeholder
        emojiTextField.text = text
        emojiTextField.delegate = context.coordinator
        emojiTextField.returnKeyType = .done
        return emojiTextField
    }
    
    func updateUIView(_ uiView: _EmojiTextField, context: Context) {
        print(#function, text, uiView.text!, isEditing, uiView.isFirstResponder)
        if isEditing == false && uiView.isFirstResponder {
            
            // this is a hacky fix for where keyboard gets immediately dismissed after tapping on text field. consistently happens in simulator but not on device. check if still presenet and remove
//            print(beganEditing?.timeIntervalSinceNow)
            if let beganEditing = self.beganEditing, abs(beganEditing.timeIntervalSinceNow) > 0.3 { // seconds
                uiView.resignFirstResponder()
            }
        } else {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EmojiTextField
        
        init(parent: EmojiTextField) {
            self.parent = parent
        }
        
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            DispatchQueue.main.async {
                self.parent.isEditing = true
            }
            return true
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.beganEditing = Date()
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                print("changed: \(textField.text!)")
                self.parent.text = textField.text ?? ""
            }
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            return string.allSatisfy(\.isEmoji)
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            print(#function, parent.text, textField.text!, parent.isEditing, textField.isFirstResponder)
            var text = textField.text ?? ""
            text = text.filter(\.isEmoji)
            text.removeRepeatingCharacters()
            DispatchQueue.main.async { [self] in
                parent.text = text
                if parent.isEditing {
                    parent.isEditing = false
                }
                parent.beganEditing = nil
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            DispatchQueue.main.async {
                self.parent.isEditing = false
            }
            return true
        }
    }
}


extension String {
    mutating func removeRepeatingCharacters() {
        var seen: Set<Character> = []
        self = String(self.filter { character in
            if !seen.contains(character) { seen.insert(character); return true }
            return false
        })
    }
}


struct EmojiTextField_Previews: PreviewProvider {
    static var previews: some View {
        EmojiTextField(text: .constant(""), isEditing: .constant(true))
    }
}
