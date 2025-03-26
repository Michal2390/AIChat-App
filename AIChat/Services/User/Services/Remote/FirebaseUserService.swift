//
//  FirebaseUserService.swift
//  AIChat
//
//  Created by Michal Fereniec on 26/03/2025.
//
import FirebaseFirestore
import SwiftfulFirestore

typealias ListenerRegistration = FirebaseFirestore.ListenerRegistration

struct FirebaseUserService: RemoteUserService {

    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }

    func saveUser(user: UserModel) async throws {
        // try collection.document(user.userId).setData(from: user, merge: true) - usual approach
        try await collection.setDocument(document: user) // SwiftfulFirestore convenience method approach because on UserModel we set StringIdentifiable with var id - we can use this
    }

    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true,
            UserModel.CodingKeys.profileColorHex.rawValue: profileColorHex
        ])
    }

    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        collection.streamDocument(id: userId)
    }

    func deleteUser(userId: String) async throws {
        // try await collection.document(userId).delete() - usual approach
        try await collection.deleteDocument(id: userId) // SwiftfulFirestore convenience method approach
    }
}
