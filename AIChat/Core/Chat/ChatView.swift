//
//  ChatView.swift
//  AIChat
//
//  Created by Michal Fereniec on 19/02/2025.
//

import SwiftUI

struct ChatView: View {

    @Environment(UserManager.self) private var userManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AIManager.self) private var aiManager
    
    @State private var chatMessages: [ChatMessageModel] = ChatMessageModel.mocks
    @State private var avatar: AvatarModel?
    @State private var currentUser: UserModel?
    @State private var chat: ChatModel?
    
    @State private var textFieldText: String = ""
    @State private var scrollPosition: String?

    @State private var showAlert: AnyAppAlert?
    @State private var showChatSettings: AnyAppAlert?
    @State private var showProfileModal: Bool = false

    var avatarId: String = AvatarModel.mock.avatarId

    var body: some View {
        VStack(spacing: 0) {
            scrollViewSection
            textFieldSection
        }
        .navigationTitle(avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "ellipsis")
                    .padding(8)
                    .anyButton {
                        onChatSettingsPressed()
                    }
            }
        }
        .showCustomAlert(type: .confirmationDialog, alert: $showChatSettings)
        .showCustomAlert(alert: $showAlert)
        .showModal(showModal: $showProfileModal) {
            if let avatar {
                profileModal(avatar: avatar)
            }
        }
        .task {
            await loadAvatar()
        }
        .onAppear {
            loadCurrentUser()
        }
    }
    
    private func loadCurrentUser() {
        currentUser = userManager.currentUser
    }

    private func loadAvatar() async {
        do {
            let avatar = try await avatarManager.getAvatar(id: avatarId)
            
            self.avatar = avatar
            try? await avatarManager.addRecentAvatar(avatar: avatar) // optional try here because I dont want to display an error if saving locally avatar will fail
        } catch {
            print("Error loading avatar: \(error)")
        }
    }
    
    private var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    let isCurrentUser = message.authorId == authManager.auth?.uid
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: currentUser?.profileColorCalculated ?? .accent,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onImagePressed: onAvatarImagePressed
                    )
                    .id(message.id)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .rotationEffect(.degrees(180)) // a trick
        }
        .rotationEffect(.degrees(180)) // to make scrollview start at the bottom
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .animation(.default, value: chatMessages.count)
        .animation(.default, value: scrollPosition)
    }

    private var textFieldSection: some View {
        TextField("Say something...", text: $textFieldText)
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 40)
            .overlay(
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .padding(.trailing, 4)
                    .foregroundStyle(.accent)
                    .anyButton(.plain, action: {
                        onSendMessagePressed()
                    })
                , alignment: .trailing
            )
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color(uiColor: .systemBackground))

                    RoundedRectangle(cornerRadius: 100)
                        .stroke(.gray.opacity(0.3), lineWidth: 1)
                }
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(uiColor: .secondarySystemBackground))
    }

    private func profileModal(avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription,
            onXMarkPressed: {
                showProfileModal = false
            }
        )
            .padding(40)
            .transition(.slide)
    }

    private func onSendMessagePressed() {
        let content = textFieldText

        Task {
            do {
                let uid = try authManager.getAuthId()
                try TextValidationHelper.checkIfTextIsValid(text: content)
                
                if chat == nil {
                    // If chat is nil, then create a new chat
                    let newChat = ChatModel.new(userId: uid, avatarId: avatarId)
                    try await chatManager.createNewChat(chat: newChat)
                    chat = newChat
                }
                
                let newChatMessage = AIChatModel(role: .user, content: content)
                let chatId = UUID().uuidString
                let message = ChatMessageModel.newUserMessage(chatId: chatId, userId: uid, message: newChatMessage)
                chatMessages.append(message)

                scrollPosition = message.id

                textFieldText = ""
                
                let aiChats = chatMessages.compactMap({ $0.content })
                
                let response = try await aiManager.generateText(chats: aiChats)                
                let newAIMessage = ChatMessageModel.newAIMessage(chatId: chatId, avatarId: avatarId, message: response)
                chatMessages.append(newAIMessage)
                
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }

    private func onChatSettingsPressed() {
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group {
                        Button("Report User / Chat", role: .destructive) {

                        }
                        Button("Delete Chat", role: .destructive) {

                        }
                    }
                )
            }
        )
    }

    private func onAvatarImagePressed() {
        showProfileModal = true
    }
}

#Preview {
    NavigationStack {
        ChatView()
            .environment(AvatarManager(remote: MockAvatarService(), local: MockLocalAvatarPersistence()))
            .previewEnvironment()
    }
}
