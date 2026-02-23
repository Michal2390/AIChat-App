//
//  LocalUserPersistence.swift
//  AIChat
//
//  Created by Michal Fereniec on 26/03/2025.
//

@MainActor
protocol LocalUserPersistence {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
}
