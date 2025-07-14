//
//  ChatsView.swift
//  AIChat
//
//  Created by Michal Fereniec on 13/01/2025.
//

import SwiftUI

struct ChatsView: View {

    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(LogManager.self) private var logManager

    @State private var chats: [ChatModel] = []
    @State private var isLoadingChats: Bool = true
    @State private var recentAvatars: [AvatarModel] = []

    @State private var path: [NavigationPathOption] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !recentAvatars.isEmpty {
                    recentsSection
                }
                chatsSection
            }
            .navigationTitle("Chats")
            .navigationDestinationForCoreModule(path: $path)
            .screenAppearAnalytics(name: "ChatsView")
            .onAppear {
                loadRecentAvatars()
            }
            .task {
                await loadChats()
            }
        }
    }

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
    
    private func loadRecentAvatars() {
        logManager.trackEvent(event: Event.loadAvatarStart)
        do {
            recentAvatars = try avatarManager.getRecentAvatars()
            logManager.trackEvent(event: Event.loadAvatarSuccess(avatarCount: recentAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }
    
    private func loadChats() async {
        logManager.trackEvent(event: Event.loadChatsStart)
        do {
            let uid = try authManager.getAuthId()
            chats = try await chatManager.getAllChats(userId: uid)
                .sortedByKeyPath(keyPath: \.dateModified, ascending: false)
            logManager.trackEvent(event: Event.loadChatsSuccess(chatsCount: chats.count))
        } catch {
            logManager.trackEvent(event: Event.loadChatsFail(error: error))
        }
        
        isLoadingChats = false
    }

    private var chatsSection: some View {
        Section {
            if isLoadingChats {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()
            } else if chats.isEmpty {
                Text("Your chats will appear here my G!")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(40)
                    .removeListRowFormatting()
            } else {
                ForEach(chats) { chat in
                    ChatRowCellViewBuilder(
                        currentUserId: authManager.auth?.uid,
                        chat: chat,
                        getAvatar: {
                            try? await avatarManager.getAvatar(id: chat.avatarId)
                        },
                        getLastChatMessage: {
                            try? await chatManager.getLastChatMessage(chatId: chat.id)
                        }
                    )
                    .anyButton(.highlight, action: {
                        onChatPressed(chat: chat)
                    })
                    .removeListRowFormatting()
                }
            }
        } header: {
            Text(chats.isEmpty ? "" : "Chats")
        }

    }

    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(recentAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName {
                            VStack(spacing: 8) {
                                ImageLoaderView(urlString: imageName)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(Circle())

                                Text(avatar.name ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .anyButton {
                                onAvatarPressed(avatar: avatar)
                            }
                        }
                    }
                }
                .padding(.top, 12)
            }
            .frame(height: 120)
            .scrollIndicators(.hidden)
            .removeListRowFormatting()
        } header: {
            Text("Recents")
        }
    }

    private func onChatPressed(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId, chat: chat))
        logManager.trackEvent(event: Event.chatPressed(chat: chat))

    }

    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
}

#Preview("Has data") {
    ChatsView()
        .previewEnvironment()
}

#Preview("No data") {
    ChatsView()
        .environment(
            AvatarManager(
                remote: MockAvatarService(avatars: []),
                local: MockLocalAvatarPersistence(avatars: [])
            )
        )
        .environment(ChatManager(service: MockChatService(chats: [])))
        .previewEnvironment()
}

#Preview("Slow loading chats") {
    ChatsView()
        .environment(ChatManager(service: MockChatService(delay: 5)))
        .previewEnvironment()
}
