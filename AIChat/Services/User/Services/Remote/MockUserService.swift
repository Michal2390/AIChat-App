//
//  MockUserService.swift
//  AIChat
//
//  Created by Michal Fereniec on 26/03/2025.
//

struct MockUserService: RemoteUserService {

    let currentUser: UserModel?

    init(user: UserModel? = nil) {
        self.currentUser = user
    }

    func saveUser(user: UserModel) async throws {

    }

    func streamUser(userId: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void ) -> AsyncThrowingStream<UserModel, Error> {
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
