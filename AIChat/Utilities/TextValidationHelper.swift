//
//  TextValidationError.swift
//  AIChat
//
//  Created by Michal Fereniec on 20/02/2025.
//
import Foundation

struct TextValidationHelper {
    
    static func checkIfTextIsValid(text: String) throws {
        let minimunCharacterCount = 4
        
        guard text.count >= minimunCharacterCount else {
            throw TextValidationError.notEnoughCharacters(min: minimunCharacterCount)
        }
        
        let badWords: [String] = [
            "shit", "bitch", "ass"
        ]
        
        if badWords.contains(text.lowercased()) {
            throw TextValidationError.hasBadWords
        }
    }
    
    enum TextValidationError: LocalizedError {
        case notEnoughCharacters(min: Int)
        case hasBadWords
        
        var errorDescription: String? {
            switch self {
            case .notEnoughCharacters(min: let min):
                return "Please add at least \(min) characters"
            case .hasBadWords:
                return "Bad word detected. Please rephrase your message"
            }
        }
    }
}
