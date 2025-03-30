//
//  LocalAvatarPersistance.swift
//  AIChat
//
//  Created by Michal Fereniec on 30/03/2025.
//
@MainActor
protocol LocalAvatarPersistance {
    func addRecentAvatar(avatar: AvatarModel) throws
    func getRecentAvatars() throws -> [AvatarModel]
}
