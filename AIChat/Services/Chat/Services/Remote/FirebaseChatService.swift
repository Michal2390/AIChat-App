//
//  FirebaseChatService.swift
//  AIChat
//
//  Created by Michal Fereniec on 11/04/2025.
//
import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseChatService: ChatService {

    private var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }

    private func messagesCollection(chatId: String) -> CollectionReference {
        collection.document(chatId).collection("messages")
    }

    func createNewChat(chat: ChatModel) async throws {
        try collection.document(chat.id).setData(from: chat, merge: true)
    }

    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
//        let result: [ChatModel] = try await collection
//            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
//            .whereField(ChatModel.CodingKeys.avatarId.rawValue, isEqualTo: avatarId)
//            .getAllDocuments()
        // return result.first
        try await collection.getDocument(id: ChatModel.chatId(userId: userId, avatarId: avatarId))
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await collection
            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
            .getAllDocuments()
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        // add the message to chat sub-collection
        try messagesCollection(chatId: chatId).document(message.id).setData(from: message, merge: true)

        try await collection.document(chatId).updateData([
            ChatModel.CodingKeys.dateModified.rawValue: Date.now
        ])
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        let messages: [ChatMessageModel] = try await messagesCollection(chatId: chatId)
            .order(by: ChatMessageModel.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: 1)
            .getAllDocuments()

        return messages.first
    }
    
    func streamChatMessages(chatId: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void ) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        messagesCollection(chatId: chatId).streamAllDocuments(onListenerConfigured: onListenerConfigured)
    }
}
