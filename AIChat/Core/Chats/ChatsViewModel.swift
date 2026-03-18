//
//  ChatsViewModel.swift
//  AIChat
//
//  Created by Michal Fereniec on 18/03/2026.
//
import SwiftUI

@MainActor
protocol ChatsInteractor {
    var auth: UserAuthInfo? { get }
    
    func trackEvent(event: LoggableEvent)
    func getRecentAvatars() throws -> [AvatarModel]
    func getAuthId() throws -> String
    func getAllChats(userId: String) async throws -> [ChatModel]
    func getAvatar(id: String) async throws -> AvatarModel
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
}

extension CoreInteractor: ChatsInteractor { }

@Observable
@MainActor
class ChatsViewModel {
    private let interactor: ChatsInteractor
    
    private(set) var chats: [ChatModel] = []
    private(set) var isLoadingChats: Bool = true
    private(set) var recentAvatars: [AvatarModel] = []

    var path: [NavigationPathOption] = [] // because of binding
    
    init(interactor: ChatsInteractor) {
        self.interactor = interactor
    }
    
    func loadRecentAvatars() {
        interactor.trackEvent(event: Event.loadAvatarStart)
        do {
            recentAvatars = try interactor.getRecentAvatars()
            interactor.trackEvent(event: Event.loadAvatarSuccess(avatarCount: recentAvatars.count))
        } catch {
            interactor.trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }
    
    func loadChats() async {
        interactor.trackEvent(event: Event.loadChatsStart)
        do {
            let uid = try interactor.getAuthId()
            chats = try await interactor.getAllChats(userId: uid)
                .sortedByKeyPath(keyPath: \.dateModified, ascending: false)
            interactor.trackEvent(event: Event.loadChatsSuccess(chatsCount: chats.count))
        } catch {
            interactor.trackEvent(event: Event.loadChatsFail(error: error))
        }
        
        isLoadingChats = false
    }
    
    func onChatPressed(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId, chat: chat))
        interactor.trackEvent(event: Event.chatPressed(chat: chat))

    }

    func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    // MARK: ChatCellRowViewBuilder logic
    var auth: UserAuthInfo? {
        interactor.auth
    }
    
    func getAvatar(for avatarId: String) async throws -> AvatarModel? {
        try await interactor.getAvatar(id: avatarId)
    }
    
    func getlastMessage(for chatId: String) async throws -> ChatMessageModel? {
        try await interactor.getLastChatMessage(chatId: chatId)
    }
    // END: ChatCellRowViewBuilder logic
    
    enum Event: LoggableEvent {
        case loadAvatarStart
        case loadAvatarSuccess(avatarCount: Int)
        case loadAvatarFail(error: Error)
        case loadChatsStart
        case loadChatsSuccess(chatsCount: Int)
        case loadChatsFail(error: Error)
        case chatPressed(chat: ChatModel)
        case avatarPressed(avatar: AvatarModel)
        
        var eventName: String {
            switch self {
            case .loadAvatarStart:        return "ChatsView_LoadAvatar_Start"
            case .loadAvatarSuccess:      return "ChatsView_LoadAvatar_Success"
            case .loadAvatarFail:         return "ChatsView_LoadAvatar_Fail"
            case .loadChatsStart:         return "ChatsView_LoadChats_Start"
            case .loadChatsSuccess:       return "ChatsView_LoadChats_Success"
            case .loadChatsFail:          return "ChatsView_LoadChats_Fail"
            case .chatPressed:            return "ChatsView_Chat_Pressed"
            case .avatarPressed:          return "ChatsView_Avatar_Pressed"
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarSuccess(avatarCount: let avatarCount):
                return [
                    "avatars_count": avatarCount
                ]
            case .loadChatsSuccess(chatsCount: let chatsCount):
                return [
                    "chats_count": chatsCount
                ]
            case .loadChatsFail(error: let error), .loadAvatarFail(error: let error):
                return error.eventParameters
            case .chatPressed(chat: let chat):
                return chat.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadChatsFail, .loadAvatarFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
