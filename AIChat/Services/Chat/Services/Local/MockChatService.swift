//
//  LocalChat.swift
//  AIChat
//
//  Created by Michal Fereniec on 11/04/2025.
//

struct MockChatService: ChatService {
    func createNewChat(chat: ChatModel) async throws { }
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws { }
}
