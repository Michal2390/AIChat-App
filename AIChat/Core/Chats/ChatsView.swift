//
//  ChatsView.swift
//  AIChat
//
//  Created by Michal Fereniec on 13/01/2025.
//
import SwiftUI

struct ChatsView: View {

    @Environment(DependencyContainer.self) private var container
    @State var viewModel: ChatsViewModel

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                if !viewModel.recentAvatars.isEmpty {
                    recentsSection
                }
                chatsSection
            }
            .navigationTitle("Chats")
            .navigationDestinationForCoreModule(path: $viewModel.path)
            .screenAppearAnalytics(name: "ChatsView")
            .onAppear {
                viewModel.loadRecentAvatars()
            }
            .task {
                await viewModel.loadChats()
            }
        }
    }

    private var chatsSection: some View {
        Section {
            if viewModel.isLoadingChats {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()
            } else if viewModel.chats.isEmpty {
                Text("Your chats will appear here my G!")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(40)
                    .removeListRowFormatting()
            } else {
                ForEach(viewModel.chats) { chat in
                    ChatRowCellViewBuilder(
                        viewModel: ChatRowCellViewModel(
                            interactor: CoreInteractor(container: container)
                        ),
                        chat: chat
                    )
                    .anyButton(.highlight, action: {
                        viewModel.onChatPressed(chat: chat)
                    })
                    .removeListRowFormatting()
                }
            }
        } header: {
            Text(viewModel.chats.isEmpty ? "" : "Chats")
        }

    }

    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(viewModel.recentAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName {
                            VStack(spacing: 8) {
                                ImageLoaderView(urlString: imageName)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(Circle())
                                    .frame(minHeight: 60)

                                Text(avatar.name ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            .anyButton {
                                viewModel.onAvatarPressed(avatar: avatar)
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
}

#Preview("Has data") {
    ChatsView(viewModel: ChatsViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvironment()
}

#Preview("No data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self) {
        AvatarManager(
            remote: MockAvatarService(avatars: []),
            local: MockLocalAvatarPersistence(avatars: [])
        )
    }
    container.register(ChatManager.self, service: ChatManager(service: MockChatService(chats: [])))
    
    return ChatsView(viewModel: ChatsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}

#Preview("Slow loading chats") {
    let container = DevPreview.shared.container
    container.register(ChatManager.self, service: ChatManager(service: MockChatService(delay: 5)))
    
    return ChatsView(viewModel: ChatsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
}
