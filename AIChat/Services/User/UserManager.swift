//
//  UserManager.swift
//  AIChat
//
//  Created by Michal Fereniec on 26/03/2025.
//
import SwiftUI

protocol UserService: Sendable {
    func saveUser(user: UserModel) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userId: String) async throws
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws
}

struct MockUserService: UserService {

    let currentUser: UserModel?

    init(user: UserModel? = nil) {
        self.currentUser = user
    }

    func saveUser(user: UserModel) async throws {

    }

    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
        }
    }

    func deleteUser(userId: String) async throws {

    }

    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws {

    }

}

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseUserService: UserService {

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

@MainActor
@Observable
class UserManager {

    private let service: UserService
    private(set) var currentUser: UserModel?
    private var currentUserListener: ListenerRegistration?

    init(service: UserService) {
        self.service = service
        self.currentUser = nil
    }

    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        try await service.saveUser(user: user)
        addCurrentUserListener(userId: auth.uid)
    }

    private func addCurrentUserListener(userId: String) {
        currentUserListener?.remove()

        Task {
            do {
                for try await value in service.streamUser(userId: userId) {
                    self.currentUser = value
                    print("Successfully listened to user: \(value.userId)")
                }
            } catch {
                print("Error attaching user listener: \(error)")
            }
        }
    }

    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserId()
        try await service.markOnboardingCompleted(userId: uid, profileColorHex: profileColorHex)
    }

    func signOut() {
        currentUserListener?.remove()
        currentUserListener = nil
        currentUser = nil
    }

    func deleteCurrentUser() async throws {
        let uid = try currentUserId()
        try await service.deleteUser(userId: currentUser?.userId ?? "")
        signOut()
    }

    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return uid
    }

    enum UserManagerError: LocalizedError {
        case noUserId
    }
}
