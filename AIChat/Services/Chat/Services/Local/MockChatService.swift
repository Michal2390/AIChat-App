//
//  LocalChat.swift
//  AIChat
//
//  Created by Michal Fereniec on 11/04/2025.
//

struct MockChatService: ChatService {
    func createNewChat(chat: ChatModel) async throws { }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        ChatModel.mock
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws { }
    
    func streamChatMessages(chatId: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void ) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        AsyncThrowingStream { _ in
            
        }
    }
}
