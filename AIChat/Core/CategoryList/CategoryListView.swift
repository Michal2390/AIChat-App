//
//  CategoryListView.swift
//  AIChat
//
//  Created by Michal Fereniec on 20/02/2025.
//

import SwiftUI

struct CategoryListView: View {

    @Environment(AvatarManager.self) private var avatarManager

    @Binding var path: [NavigationPathOption]
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImage
    @State private var avatars: [AvatarModel] = []
    @State private var isLoading: Bool = true

    @State private var showAlert: AnyAppAlert?

    var body: some View {
        List {
            CategoryCellView(
                title: category.plural.capitalized,
                imageName: imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()

            if isLoading {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else if avatars.isEmpty {
                Text("No avatars found 😢")
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else {
                ForEach(avatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: avatar.characterDescription
                    )
                    .anyButton(.highlight, action: {
                        onAvatarPressed(avatar: avatar)
                    })
                    .removeListRowFormatting()
                }
            }
        }
        .showCustomAlert(alert: $showAlert)
        .ignoresSafeArea()
        .listStyle(PlainListStyle())
        .task {
            await loadAvatars()
        }
    }

    private func loadAvatars() async {
        do {
            avatars = try await avatarManager.getAvatarsForCategory(category: category)
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
        isLoading = false
    }

    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId))
    }
}

#Preview("Has data") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(remote: MockAvatarService()))
}

#Preview("No data") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(remote: MockAvatarService(avatars: [])))
}

#Preview("Slow loading") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(remote: MockAvatarService(delay: 10)))
}

#Preview("Error loading") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(remote: MockAvatarService(delay: 5, showError: true)))
}
