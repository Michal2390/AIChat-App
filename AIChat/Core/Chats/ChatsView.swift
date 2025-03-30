//
//  ChatsView.swift
//  AIChat
//
//  Created by Michal Fereniec on 13/01/2025.
//

import SwiftUI

struct ChatsView: View {

    @Environment(AvatarManager.self) private var avatarManager
    
    @State private var chats: [ChatModel] = ChatModel.mocks
    @State private var recentsAvatars: [AvatarModel] = AvatarModel.mocks

    @State private var path: [NavigationPathOption] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !recentsAvatars.isEmpty {
                    recentsSection
                }
                chatsSection
            }
            .navigationTitle("Chats")
            .navigationDestinationForCoreModule(path: $path)
            .onAppear {
                loadRecentAvatars()
            }
        }
    }
    
    private func loadRecentAvatars() {
        do {
            recentsAvatars = try avatarManager.getRecentAvatars()
        } catch {
            print("Failed to load recents")
        }
    }

    private var chatsSection: some View {
        Section {
            if chats.isEmpty {
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
                        currentUserId: nil, // FIXME: Add cuid
                        chat: chat,
                        getAvatar: {
                            try? await Task.sleep(for: .seconds(1))
                            return .mock
                        },
                        getLastChatMessage: {
                            try? await Task.sleep(for: .seconds(1))
                            return .mock
                        }
                    )
                    .anyButton(.highlight, action: {
                        onChatPressed(chat: chat)
                    })
                    .removeListRowFormatting()
                }
            }
        } header: {
            Text("Chats")
        }

    }

    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(recentsAvatars, id: \.self) { avatar in
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
        path.append(.chat(avatarId: chat.avatarId))
    }

    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId))
    }
}

#Preview {
    ChatsView()
        .environment(AvatarManager(remote: MockAvatarService()))
}
