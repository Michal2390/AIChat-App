//
//  ChatBubbleViewBuilder.swift
//  AIChat
//
//  Created by Michal Fereniec on 19/02/2025.
//

import SwiftUI

struct ChatBubbleViewBuilder: View {

    var message: ChatMessageModel = .mock
    var isCurrentUser: Bool = false
    var currentUserProfileColor: Color = .accent
    var imageName: String?
    var onImagePressed: (() -> Void)?

    var body: some View {
        ZStack {
            ChatBubbleView(
                text: message.content?.message ?? "",
                textColor: isCurrentUser ? .white : .primary,
                backgroundColor: isCurrentUser ? currentUserProfileColor : Color(uiColor: .systemGray6),
                showImage: !isCurrentUser,
                imageName: imageName,
                onImagePressed: onImagePressed
            )
            .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
            .padding(.leading, isCurrentUser ? 75 : 0)
            .padding(.trailing, isCurrentUser ? 0 : 75)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            ChatBubbleViewBuilder()
            ChatBubbleViewBuilder(isCurrentUser: true)
            ChatBubbleViewBuilder(
                message: ChatMessageModel(
                    id: UUID().uuidString,
                    chatId: UUID().uuidString,
                    authorId: UUID().uuidString,
                    content: AIChatModel(role: .user, content: "This is some longer content that goes on to mutliple lines and keep on going to another line!"),
                    seenByIds: nil,
                    dateCreated: .now
                )
            )
            ChatBubbleViewBuilder(
                message: ChatMessageModel(
                    id: UUID().uuidString,
                    chatId: UUID().uuidString,
                    authorId: UUID().uuidString,
                    content: AIChatModel(role: .user, content: "This is some longer content that goes on to mutliple lines and keep on going to another line!"),
                    seenByIds: nil,
                    dateCreated: .now
                ),
                isCurrentUser: true,
                currentUserProfileColor: .blue
            )

        }
        .padding(12)
    }
}
