//
//  FirebaseChatService.swift
//  AIChat
//
//  Created by Michal Fereniec on 11/04/2025.
//
import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseChatService: ChatService {
   
    var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try collection.document(chat.id).setData(from: chat, merge: true)
    }
}
