//
//  ChatModel.swift
//  AIChat
//
//  Created by Michal Fereniec on 18/02/2025.
//
import Foundation

struct ChatModel: Identifiable {
    let id: String
    let userId: String
    let avatarId: String
    let dataCreated: Date
    let dateModified: Date

    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            ChatModel(id: "mock_chat_1", userId: "user1", avatarId: "avatar1", dataCreated: now, dateModified: now),
            ChatModel(id: "mock_chat_2", userId: "user2", avatarId: "avatar2", dataCreated: now.addingTimeInterval(hours: -1), dateModified: now.addingTimeInterval(minutes: -30)),
            ChatModel(id: "mock_chat_3", userId: "user3", avatarId: "avatar3", dataCreated: now.addingTimeInterval(hours: -2), dateModified: now.addingTimeInterval(hours: -1)),
            ChatModel(id: "mock_chat_4", userId: "user4", avatarId: "avatar4", dataCreated: now.addingTimeInterval(days: -1), dateModified: now.addingTimeInterval(hours: -10))
        ]
    }
}
