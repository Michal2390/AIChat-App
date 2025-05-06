//
//  RemoteUserService.swift
//  AIChat
//
//  Created by Michal Fereniec on 26/03/2025.
//

protocol RemoteUserService: Sendable {
    func saveUser(user: UserModel) async throws
    func streamUser(userId: String, onListenerConfigured: @escaping (ListenerRegistration) -> Void ) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userId: String) async throws
    func markOnboardingCompleted(userId: String, profileColorHex: String) async throws
}
