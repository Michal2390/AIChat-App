//
//  LocalChat.swift
//  AIChat
//
//  Created by Michal Fereniec on 11/04/2025.
//

import Foundation

struct MockChatService: ChatService {
    
    let chats: [ChatModel]
    let delay: Double
    let showError: Bool
    
    init(chats: [ChatModel] = ChatModel.mocks, delay: Double = 0.0, showError: Bool = false) {
        self.chats = chats
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func createNewChat(chat: ChatModel) async throws { }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return chats.first { chat in
            return chat.userId == userId && chat.avatarId == avatarId
            
        }
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return chats
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws { }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return ChatMessageModel.mocks.randomElement()
    }
    
    func streamChatMessages(chatId: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void ) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        AsyncThrowingStream { _ in
            
        }
    }
}
