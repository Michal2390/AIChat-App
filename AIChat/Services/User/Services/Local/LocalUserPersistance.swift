//
//  LocalUserPersistance.swift
//  AIChat
//
//  Created by Michal Fereniec on 26/03/2025.
//

protocol LocalUserPersistance {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
}
