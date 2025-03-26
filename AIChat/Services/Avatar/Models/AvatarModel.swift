//
//  AvatarModel.swift
//  AIChat
//
//  Created by Michal Fereniec on 25/01/2025.
//

import Foundation

struct AvatarModel: Hashable {

    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    let profileImageName: String?
    let authorId: String?
    let dateCreated: Date?

    init(
        avatarId: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authorId: String? = nil,
        dateCreated: Date? = nil
    ) {
        self.avatarId = avatarId
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authorId = authorId
        self.dateCreated = dateCreated
    }

    var characterDescription: String {
        AvatarDescriptionBuilder(avatar: self).characterDescription
    }

    static var mock: Self {
        mocks[0]
    }

    static var mocks: [Self] {
        [
            AvatarModel(avatarId: UUID().uuidString, name: "Alpha", characterOption: .alien, characterAction: .fighting, characterLocation: .space, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now),
            AvatarModel(avatarId: UUID().uuidString, name: "Beta", characterOption: .cat, characterAction: .drinking, characterLocation: .forest, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now),
            AvatarModel(avatarId: UUID().uuidString, name: "Gamma", characterOption: .man, characterAction: .relaxing, characterLocation: .park, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now),
            AvatarModel(avatarId: UUID().uuidString, name: "Delta", characterOption: .woman, characterAction: .shopping, characterLocation: .mall, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now),
            AvatarModel(avatarId: UUID().uuidString, name: "Omega", characterOption: .dog, characterAction: .sleeping, characterLocation: .desert, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now)
        ]
    }
}
