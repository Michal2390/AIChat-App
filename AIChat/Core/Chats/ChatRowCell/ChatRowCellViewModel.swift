//
//  ChatRowCellViewModel.swift
//  AIChat
//
//  Created by Michal Fereniec on 23/03/2026.
//
import SwiftUI

@MainActor
protocol ChatRowCellInteractor {
    var auth: UserAuthInfo? { get }
    func trackEvent(event: LoggableEvent)
    func getAvatar(id: String) async throws -> AvatarModel
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
}

extension CoreInteractor: ChatRowCellInteractor { }

@MainActor
struct AnyChatRowCellInteractor: ChatRowCellInteractor {
    let anyAuth: UserAuthInfo?
    let anyTrackEvent: ((LoggableEvent) -> Void)?
    let anyGetAvatar: (String) async throws -> AvatarModel
    let anyGetLastChatMessage: (String) async throws -> ChatMessageModel?
    
    init(
        auth: UserAuthInfo? = .mock(),
        trackEvent: ((LoggableEvent) -> Void)? = nil,
        getAvatar: @escaping (String) async throws -> AvatarModel,
        getLastChatMessage: @escaping (String) async throws -> ChatMessageModel?
    ) {
        self.anyAuth = auth
        self.anyTrackEvent = trackEvent
        self.anyGetAvatar = getAvatar
        self.anyGetLastChatMessage = getLastChatMessage
    }
    
    init(interactor: ChatRowCellInteractor) {
        self.anyAuth = interactor.auth
        self.anyTrackEvent = interactor.trackEvent
        self.anyGetAvatar = interactor.getAvatar
        self.anyGetLastChatMessage = interactor.getLastChatMessage
    }
    
    var auth: UserAuthInfo? {
        anyAuth
    }
    
    func trackEvent(event: LoggableEvent) {
        anyTrackEvent?(event)
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await anyGetAvatar(id)
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await anyGetLastChatMessage(chatId)
    }
}

@Observable
@MainActor
class ChatRowCellViewModel {
    
    private let interactor: ChatRowCellInteractor

    private(set) var avatar: AvatarModel?
    private(set) var lastChatMessage: ChatMessageModel?

    private(set) var didLoadAvatar: Bool = false
    private(set) var didLoadChatMessage: Bool = false

    var isLoading: Bool {
        (didLoadAvatar && didLoadChatMessage) ? false : true
    }
    
    var hasNewChat: Bool {
        guard let lastChatMessage, let currentUserId = interactor.auth?.uid else { return false }
        return !lastChatMessage.hasBeenSeenBy(userId: currentUserId)
    }

    var subheadline: String? {
        if isLoading {
            return "loading..."
        }
        if avatar == nil && lastChatMessage == nil {
            return "Error loading data."
        }

        return lastChatMessage?.content?.message
    }
    
    init(interactor: ChatRowCellInteractor) {
        self.interactor = interactor
    }
    
    func loadAvatar(chat: ChatModel) async {
        avatar = try? await interactor.getAvatar(id: chat.avatarId)
        didLoadAvatar = true
    }
    
    func loadLastChatMessage(chat: ChatModel) async {
        lastChatMessage = try? await interactor.getLastChatMessage(chatId: chat.id)
        didLoadChatMessage = true
    }
}
