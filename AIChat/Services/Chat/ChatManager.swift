//
//  ChatManager.swift
//  AIChat
//
//  Created by Michal Fereniec on 11/04/2025.
//
import SwiftUI

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func getAllChats(userId: String) async throws -> [ChatModel]
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
    func streamChatMessages(chatId: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void ) -> AsyncThrowingStream<[ChatMessageModel], Error>
}

@MainActor
@Observable
class ChatManager {
    
    private let service: ChatService

    init(service: ChatService) {
        self.service = service
    }

    func createNewChat(chat: ChatModel) async throws {
        try await service.createNewChat(chat: chat)
    }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await service.getChat(userId: userId, avatarId: avatarId)
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await service.getAllChats(userId: userId)
    }

    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        try await service.addChatMessage(chatId: chatId, message: message)
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await service.getLastChatMessage(chatId: chatId)
    }
    
    func streamChatMessages(chatId: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void ) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        service.streamChatMessages(chatId: chatId, onListenerConfigured: onListenerConfigured)
    }
}
