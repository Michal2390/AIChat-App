//
//  MockAvatarService.swift
//  AIChat
//
//  Created by Michal Fereniec on 30/03/2025.
//
import SwiftUI

struct MockAvatarService: RemoteAvatarService {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await Task.sleep(for: .seconds(2))
        return AvatarModel.mock
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(1))
        return AvatarModel.mocks.shuffled()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(2))
        return AvatarModel.mocks.shuffled()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(2))
        return AvatarModel.mocks.shuffled()
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await Task.sleep(for: .seconds(2))
        return AvatarModel.mocks.shuffled()
    }
    
    func incrementAvatarClickCount(avatarId: String) async throws {
        
    }
}
