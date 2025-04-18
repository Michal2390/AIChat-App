//
//  ChatManager.swift
//  AIChat
//
//  Created by Michal Fereniec on 11/04/2025.
//
import SwiftUI

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
}

@MainActor
@Observable
class ChatManager: ChatService {
    private let service: ChatService
    
    init(service: ChatService) {
        self.service = service
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try await service.createNewChat(chat: chat)
    }
}
