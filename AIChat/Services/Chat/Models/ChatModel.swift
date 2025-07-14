//
//  ChatModel.swift
//  AIChat
//
//  Created by Michal Fereniec on 18/02/2025.
//
import Foundation
import IdentifiableByString

struct ChatModel: Identifiable, Codable, Hashable, StringIdentifiable {
    let id: String
    let userId: String
    let avatarId: String
    let dataCreated: Date
    let dateModified: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case avatarId = "avatar_id"
        case dataCreated = "date_created"
        case dateModified = "date_modified"
    }

    var eventParameters: [String: Any] {
        let dictionary: [String: Any?] = [
            "chat_\(CodingKeys.id.rawValue)": id,
            "chat_\(CodingKeys.userId.rawValue)": userId,
            "chat_\(CodingKeys.avatarId.rawValue)": avatarId,
            "chat_\(CodingKeys.dataCreated.rawValue)": dataCreated,
            "chat_\(CodingKeys.dateModified.rawValue)": dateModified
        ]
        return dictionary.compactMapValues({ $0 })
    }
    
    static func chatId(userId: String, avatarId: String) -> String {
        "\(userId)_\(avatarId)"
    }

    static func new(userId: String, avatarId: String) -> Self {
        ChatModel(
            id: chatId(userId: userId, avatarId: avatarId),
            userId: userId,
            avatarId: avatarId,
            dataCreated: .now,
            dateModified: .now
        )
    }

    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            ChatModel(
                id: "mock_chat_1",
                userId: UserAuthInfo.mock().uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dataCreated: now,
                dateModified: now
            ),
            ChatModel(
                id: "mock_chat_2",
                userId: UserAuthInfo.mock().uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dataCreated: now.addingTimeInterval(
                    hours: -1
                ),
                dateModified: now.addingTimeInterval(
                    minutes: -30
                )
            ),
            ChatModel(
                id: "mock_chat_3",
                userId: UserAuthInfo.mock().uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dataCreated: now.addingTimeInterval(
                    hours: -2
                ),
                dateModified: now.addingTimeInterval(
                    hours: -1
                )
            ),
            ChatModel(
                id: "mock_chat_4",
                userId: UserAuthInfo.mock().uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dataCreated: now.addingTimeInterval(
                    days: -1
                ),
                dateModified: now.addingTimeInterval(
                    hours: -10
                )
            )
        ]
    }
}
