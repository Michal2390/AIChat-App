//
//  ProfileView.swift
//  AIChat
//
//  Created by Michal Fereniec on 13/01/2025.
//

import SwiftUI

struct ProfileView: View {

    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AuthManager.self) private var authManager

    @State private var showSettingsView: Bool = false
    @State private var showCreateAvatarView: Bool = false
    @State private var currentUser: UserModel?
    @State private var myAvatars: [AvatarModel] = []
    @State private var isLoading: Bool = true
    @State private var showAlert: AnyAppAlert?

    @State private var path: [NavigationPathOption] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                myInfoSection
                myAvatarsSection
            }
            .navigationTitle("Profile")
            .navigationDestinationForCoreModule(path: $path)
            .showCustomAlert(alert: $showAlert)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                }
            }
        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showCreateAvatarView, onDismiss: {
            Task {
                await loadData()
            }
        }, content: {
            CreateAvatarView()
        })
        .fullScreenCover(isPresented: $showCreateAvatarView) {
            CreateAvatarView()
        }
        .task {
            await loadData()
        }
    }

    private func loadData() async {
        self.currentUser = userManager.currentUser

        do {
            let uid = try authManager.getAuthId()
            myAvatars = try await avatarManager.getAvatarsForAuthor(userId: uid)
        } catch {
            print("Failed to fetch avatars")
        }
        try? await Task.sleep(for: .seconds(5))
        isLoading = false
    }

    private var myInfoSection: some View {
        Section {
            ZStack {
                Circle()
                    .fill(currentUser?.profileColorCalculated ?? .accent)
            }
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity)
            .removeListRowFormatting()
        }
    }

    private var myAvatarsSection: some View {
        Section {
            if myAvatars.isEmpty {
                Group {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Click + to create an avatar")
                    }
                }
                .padding(50)
                .frame(maxWidth: .infinity)
                .font(.body)
                .foregroundStyle(.secondary)
                .removeListRowFormatting()
            }
            ForEach(myAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: nil
                )
                .anyButton(.highlight, action: {
                    onAvatarPressed(avatar: avatar)
                })
                .removeListRowFormatting()
            }
            .onDelete { indexSet in
                onDeleteAvatar(indexSet: indexSet)
            }
        } header: {
            HStack(spacing: 0) {
                Text("My avatars")
                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(.accent)
                    .anyButton {
                        onNewAvatarButtonPressed()
                    }
            }
        }
    }

    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                onSettingsButtonPressed()
            }
    }

    private func onSettingsButtonPressed() {
        showSettingsView = true
    }

    private func onNewAvatarButtonPressed() {
        showCreateAvatarView = true
    }

    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }

    private func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatar = myAvatars[index]

        Task {
            do {
                try await avatarManager.removeAuthorIdFromAvatar(avatarId: avatar.id)
                myAvatars.remove(at: index)
            } catch {
                showAlert = AnyAppAlert(title: "Unable to delete avatar", subtitle: "Please try again.")
            }
        }
    }
}

#Preview {
    ProfileView()
        .previewEnvironment()
}
