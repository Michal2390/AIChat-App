//
//  MockLocalAvatarPersistence.swift
//  AIChat
//
//  Created by Michal Fereniec on 30/03/2025.
//
@MainActor
struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    
    let avatars: [AvatarModel]
    
    init(avatars: [AvatarModel] = AvatarModel.mocks) {
        self.avatars = avatars
    }
    
    func addRecentAvatar(avatar: AvatarModel) throws { }

    func getRecentAvatars() throws -> [AvatarModel] {
        return avatars
    }
}
