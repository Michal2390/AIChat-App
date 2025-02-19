//
//  AvatarAttributes.swift
//  AIChat
//
//  Created by Michal Fereniec on 19/02/2025.
//
enum CharacterOption: String, CaseIterable, Hashable {
    case man, woman, alien, dog, cat, elephant
    
    static var `default`: Self {
        .man
    }
    
    var startsWithVowel: Bool {
        switch self { 
        case .alien:
            return true
        default:
            return false
        }
    }
}

enum CharacterAction: String, CaseIterable, Hashable {
    case eating, drinking, sleeping, smiling, sitting, walking, shopping, studying, working, relaxing, fighting, crying, laughing
    
    static var `default`: Self {
        .smiling
    }
}

enum CharacterLocation: String, CaseIterable, Hashable {
    case park, mall, museum, city, desert, forest, beach, mountain, space
    
    static var `default`: Self {
        .museum
    }
}

struct AvatarDescriptionBuilder {
    let characterOption: CharacterOption
    let characterAction: CharacterAction
    let characterLocation: CharacterLocation
    
    init(characterOption: CharacterOption, characterAction: CharacterAction, characterLocation: CharacterLocation) {
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
    }
    
    init(avatar: AvatarModel) {
        self.characterOption = avatar.characterOption ?? .default
        self.characterAction = avatar.characterAction ?? .default
        self.characterLocation = avatar.characterLocation ?? .default
    }
    
    var characterDescription: String {
        let prefix = characterOption.startsWithVowel ? "An" : "A"
        return "\(prefix) \(characterOption) that is \(characterAction) in the \(characterLocation)."
    }
}
