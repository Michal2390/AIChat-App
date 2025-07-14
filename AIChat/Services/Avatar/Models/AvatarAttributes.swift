//
//  AvatarAttributes.swift
//  AIChat
//
//  Created by Michal Fereniec on 19/02/2025.
//
enum CharacterOption: String, CaseIterable, Hashable, Codable {
    case man, woman, alien, dog, cat, elephant

    static var `default`: Self {
        .man
    }

    var plural: String {
        switch self {
        case .man:
            return "men"
        case .woman:
            return "woman"
        case .alien:
            return "aliens"
        case .dog:
            return "dogs"
        case .cat:
            return "cats"
        case .elephant:
            return "elephants"
        }
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

enum CharacterAction: String, CaseIterable, Hashable, Codable {
    case eating, drinking, sleeping, smiling, sitting, walking, shopping, studying, working, relaxing, fighting, crying, laughing

    static var `default`: Self {
        .smiling
    }
}

enum CharacterLocation: String, CaseIterable, Hashable, Codable {
    case park, mall, museum, city, desert, forest, beach, mountain, space

    static var `default`: Self {
        .museum
    }
}

struct AvatarDescriptionBuilder: Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case characterOption = "character_option"
        case characterAction = "character_action"
        case characterLocation = "character_location"
    }

    var characterDescription: String {
        let prefix = characterOption.startsWithVowel ? "An" : "A"
        return "\(prefix) \(characterOption) that is \(characterAction) in the \(characterLocation)."
    }
    
    var eventParameters: [String: Any] {
     [
        CodingKeys.characterOption.rawValue: characterOption.rawValue,
        CodingKeys.characterAction.rawValue: characterAction.rawValue,
        CodingKeys.characterLocation.rawValue: characterLocation.rawValue,
        "character_description": characterDescription
     ]
    }
}
