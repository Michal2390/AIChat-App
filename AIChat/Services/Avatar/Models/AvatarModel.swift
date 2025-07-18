//
//  AvatarModel.swift
//  AIChat
//
//  Created by Michal Fereniec on 25/01/2025.
//

import Foundation
import IdentifiableByString

struct AvatarModel: Hashable, Codable, StringIdentifiable {
    var id: String {
        avatarId
    }

    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    private(set) var profileImageName: String? // adding private(set) var here makes it still var but we can change this variable only from within the variable, so that the setter is private
    let authorId: String?
    let dateCreated: Date?
    let clickCount: Int?

    init(
        avatarId: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authorId: String? = nil,
        dateCreated: Date? = nil,
        clickCount: Int? = nil
    ) {
        self.avatarId = avatarId
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authorId = authorId
        self.dateCreated = dateCreated
        self.clickCount = clickCount
    }

    var characterDescription: String {
        AvatarDescriptionBuilder(avatar: self).characterDescription
    }

    mutating func updateProfileImage(imageName: String) { // mutating will mutate the struct that it is inside
        profileImageName = imageName
    }

    enum CodingKeys: String, CodingKey {
        case avatarId = "avatar_id"
        case name
        case characterOption = "character_option"
        case characterAction = "character_action"
        case characterLocation = "character_location"
        case profileImageName = "profile_image_name"
        case authorId = "author_id"
        case dateCreated = "date_created"
        case clickCount = "click_count"
    }
    
    var eventParameters: [String: Any] {
        let dictionary: [String: Any?] = [
            "avatar_\(CodingKeys.avatarId.rawValue)": avatarId,
            "avatar_\(CodingKeys.name.rawValue)": name,
            "avatar_\(CodingKeys.characterOption.rawValue)": characterOption?.rawValue,
            "avatar_\(CodingKeys.characterAction.rawValue)": characterAction?.rawValue,
            "avatar_\(CodingKeys.characterLocation.rawValue)": characterLocation?.rawValue,
            "avatar_\(CodingKeys.profileImageName.rawValue)": profileImageName,
            "avatar_\(CodingKeys.authorId.rawValue)": authorId,
            "avatar_\(CodingKeys.dateCreated.rawValue)": dateCreated,
            "avatar_\(CodingKeys.clickCount.rawValue)": clickCount
        ]
        return dictionary.compactMapValues({ $0 })
    }

    static func newAvatar(name: String, option: CharacterOption, action: CharacterAction, location: CharacterLocation, authorId: String) -> Self {
        AvatarModel(
            avatarId: UUID().uuidString,
            name: name,
            characterOption: option,
            characterAction: action,
            characterLocation: location,
            profileImageName: nil,
            authorId: authorId,
            dateCreated: .now,
            clickCount: 0
        )
    }

    static var mock: Self {
        mocks[0]
    }

    static var mocks: [Self] {
        [
            AvatarModel(avatarId: "mock_ava_1", name: "Alpha", characterOption: .alien, characterAction: .fighting, characterLocation: .space, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now, clickCount: 10),
            AvatarModel(avatarId: "mock_ava_2", name: "Beta", characterOption: .cat, characterAction: .drinking, characterLocation: .forest, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now, clickCount: 69),
            AvatarModel(avatarId: "mock_ava_3", name: "Gamma", characterOption: .man, characterAction: .relaxing, characterLocation: .park, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now, clickCount: 420),
            AvatarModel(avatarId: "mock_ava_4", name: "Delta", characterOption: .woman, characterAction: .shopping, characterLocation: .mall, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now, clickCount: 23),
            AvatarModel(avatarId: "mock_ava_5", name: "Omega", characterOption: .dog, characterAction: .sleeping, characterLocation: .desert, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now, clickCount: 5)
        ]
    }
}
