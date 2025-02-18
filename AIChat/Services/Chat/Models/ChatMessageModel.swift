//
//  ChatMessageModel.swift
//  AIChat
//
//  Created by Michal Fereniec on 18/02/2025.
//
import Foundation

struct ChatMessageModel {
    let id: String
    let chatId: String
    let authorId: String?
    let content: String?
    let seenByIds: [String]?
    let dateCreated: Date?
    
    init(
        id: String,
        chatId: String,
        authorId: String? = nil,
        content: String? = nil,
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
    
    func hasBeenSeenBy(userId: String) -> Bool {
        guard let seenByIds else { return false }
        return seenByIds.contains(userId)
    }
    
    static var mock: ChatMessageModel {
        mocks[0]
    }
    
    static var mocks: [ChatMessageModel] {
        let now = Date()
        return [
            ChatMessageModel(id: "mock_Message_chat_1", chatId: "1", authorId: "user1", content: "Hello, how are u my G?", seenByIds: ["user2", "user3"], dateCreated: now),
            ChatMessageModel(id: "mock_Message_chat_1", chatId: "1", authorId: "user2", content: "I am feeling thank you", seenByIds: ["user1"], dateCreated: now.addingTimeInterval(minutes: -5)),
            ChatMessageModel(id: "mock_Message_chat_1", chatId: "1", authorId: "user3", content: "Anything is possible - and Jayson Tatum has Aura", seenByIds: ["user1", "user2", "user4"], dateCreated: now.addingTimeInterval(hours: -1)),
            ChatMessageModel(id: "mock_Message_chat_1", chatId: "1", authorId: "user1", content: "Luka in Lakers? Bro thats crazy", seenByIds: nil, dateCreated: now.addingTimeInterval(hours: -5, minutes: -30))
        ]
    }
}
