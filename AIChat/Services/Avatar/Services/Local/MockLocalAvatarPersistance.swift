//
//  MockLocalAvatarPersistence.swift
//  AIChat
//
//  Created by Michal Fereniec on 30/03/2025.
//
@MainActor
struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    func addRecentAvatar(avatar: AvatarModel) throws { }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
}
