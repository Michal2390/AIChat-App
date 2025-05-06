//
//  ChatMessageModel.swift
//  AIChat
//
//  Created by Michal Fereniec on 18/02/2025.
//
import Foundation

struct ChatMessageModel: Identifiable, Codable {
    let id: String
    let chatId: String
    let authorId: String?
    let content: AIChatModel?
    let seenByIds: [String]?
    let dateCreated: Date?

    init(
        id: String,
        chatId: String,
        authorId: String? = nil,
        content: AIChatModel? = nil,
        seenByIds: [String]? = nil,
        dateCreated: Date? = nil
    ) {
        self.id = id
        self.chatId = chatId
        self.authorId = authorId
        self.content = content
        self.seenByIds = seenByIds
        self.dateCreated = dateCreated
    }
    
    var dateCreatedCalculated: Date {
        dateCreated ?? .distantPast
    }

    func hasBeenSeenBy(userId: String) -> Bool {
        guard let seenByIds else { return false }
        return seenByIds.contains(userId)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case authorId = "author_id"
        case content
        case seenByIds = "seen_by_ids"
        case dateCreated = "date_created"
    }

    static func newUserMessage(chatId: String, userId: String, message: AIChatModel) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: userId,
            content: message,
            seenByIds: [userId],
            dateCreated: .now
        )
    }

    static func newAIMessage(chatId: String, avatarId: String, message: AIChatModel) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: avatarId,
            content: message,
            seenByIds: [],
            dateCreated: .now
        )
    }

    static var mock: Self {
        mocks[0]
    }

    static var mocks: [Self] {
        let now = Date()
        return [
            ChatMessageModel(
                id: "mock_Message_chat_1",
                chatId: "1",
                authorId: UserAuthInfo.mock().uid,
                content: AIChatModel(role: .user, content: "Did u see that Luka is in the Lakers?"),
                seenByIds: [
                    "user2",
                    "user3"
                ],
                dateCreated: now
            ),
            ChatMessageModel(
                id: "mock_Message_chat_2",
                chatId: "2",
                authorId: AvatarModel.mock.avatarId,
                content: AIChatModel(role: .assistant, content: "Damn bro, didnt see that yet, my G"),
                seenByIds: ["user1"],
                dateCreated: now.addingTimeInterval(
                    minutes: -5
                )
            ),
            ChatMessageModel(
                id: "mock_Message_chat_3",
                chatId: "3",
                authorId: UserAuthInfo.mock().uid,
                content: AIChatModel(role: .user, content: "Anything is possible - and Jayson Tatum has aura"),
                seenByIds: [
                    "user1",
                    "user2",
                    "user4"
                ],
                dateCreated: now.addingTimeInterval(
                    hours: -1
                )
            ),
            ChatMessageModel(
                id: "mock_Message_chat_4",
                chatId: "1",
                authorId: AvatarModel.mock.avatarId,
                content: AIChatModel(role: .assistant, content: "Cant agree more, but still Lakers in 5 bro"),
                seenByIds: nil,
                dateCreated: now.addingTimeInterval(
                    hours: -5,
                    minutes: -30
                )
            )
        ]
    }
}
