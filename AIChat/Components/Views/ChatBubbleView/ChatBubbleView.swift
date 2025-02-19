//
//  ChatBubbleView.swift
//  AIChat
//
//  Created by Michal Fereniec on 19/02/2025.
//

import SwiftUI

struct ChatBubbleView: View {
    
    var text: String = "This is a sample text"
    var textColor: Color = .primary
    var backgroundColor: Color = Color(uiColor: .systemGray6)
    var showImage: Bool = true
    var imageName: String?
    
    let offset: CGFloat = 14
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if showImage {
                ZStack {
                    if let imageName {
                        ImageLoaderView(urlString: imageName)
                    } else {
                        Rectangle()
                            .fill(.secondary)
                    }
                }
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .offset(y: 14)
            }
            
            Text(text)
                .font(.body)
                .foregroundStyle(textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(backgroundColor)
                .cornerRadius(6)
        }
        .padding(.bottom, showImage ? offset : 0)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ChatBubbleView()
            ChatBubbleView(text: "this is a chat bubble witha  lot of text my nigga and this is a chat bubble witha  lot of text my nigga and this is a chat bubble witha  lot of text my nigga and this is a chat bubble witha  lot of text my nigga and this is a chat bubble witha  lot of text my nigga and ")
            
            ChatBubbleView(
                textColor: .white,
                backgroundColor: .accent,
                showImage: false,
                imageName: nil
            )
            ChatBubbleView(text: "this is a chat bubble witha  lot of text my nigga and this is a chat bubble witha  lot of text my nigga and this is a chat bubble witha  lot of text my nigga and this is a chat bubble witha  lot of text my nigga and this is a chat bubble witha  lot of text my nigga and ",
                           textColor: .white,
                           backgroundColor: .accent,
                           imageName: nil
            )
        }
        .padding(8)
    }
}
