//
//  ProfileView.swift
//  AIChat
//
//  Created by Michal Fereniec on 13/01/2025.
//

import SwiftUI

@Observable
@MainActor
class ProfileViewModel {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let avatarManager: AvatarManager
    private let logManager: LogManager
        
    private(set) var currentUser: UserModel?
    private(set) var myAvatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true
    
    var showSettingsView: Bool = false
    var showCreateAvatarView: Bool = false
    var showAlert: AnyAppAlert?
    var path: [NavigationPathOption] = []
    
    init(authManager: AuthManager, userManager: UserManager, avatarManager: AvatarManager, logManager: LogManager) {
        self.authManager = authManager
        self.userManager = userManager
        self.avatarManager = avatarManager
        self.logManager = logManager
    }

    func loadData() async {
        self.currentUser = userManager.currentUser
        logManager.trackEvent(event: Event.loadAvatarsStart)

        do {
            let uid = try authManager.getAuthId()
            myAvatars = try await avatarManager.getAvatarsForAuthor(userId: uid)
            logManager.trackEvent(event: Event.loadAvatarsSuccess(count: myAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
        try? await Task.sleep(for: .seconds(5))
        isLoading = false
    }
    
    func onSettingsButtonPressed() {
        showSettingsView = true
        logManager.trackEvent(event: Event.settingsPressed)
    }

    func onNewAvatarButtonPressed() {
        showCreateAvatarView = true
        logManager.trackEvent(event: Event.newAvatarPressed)
    }

    func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }

    func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatar = myAvatars[index]
        logManager.trackEvent(event: Event.deleteAvatarStart(avatar: avatar))

        Task {
            do {
                try await avatarManager.removeAuthorIdFromAvatar(avatarId: avatar.id)
                myAvatars.remove(at: index)
                logManager.trackEvent(event: Event.deleteAvatarSuccess(avatar: avatar))
            } catch {
                showAlert = AnyAppAlert(title: "Unable to delete avatar", subtitle: "Please try again.")
                logManager.trackEvent(event: Event.deleteAvatarFail(error: error))
            }
        }
    }
    
    enum Event: LoggableEvent {
        case loadAvatarsStart
        case loadAvatarsSuccess(count: Int)
        case loadAvatarsFail(error: Error)
        case settingsPressed
        case newAvatarPressed
        case avatarPressed(avatar: AvatarModel)
        case deleteAvatarStart(avatar: AvatarModel)
        case deleteAvatarSuccess(avatar: AvatarModel)
        case deleteAvatarFail(error: Error)
        
        var eventName: String {
            switch self {
            case .loadAvatarsStart:          return "ProfileView_LoadAvatar_Start"
            case .loadAvatarsSuccess:        return "ProfileView_LoadAvatar_Success"
            case .loadAvatarsFail:           return "ProfileView_LoadAvatar_Fail"
            case .settingsPressed:           return "ProfileView_Settings_Pressed"
            case .newAvatarPressed:          return "ProfileView_NewAvatar_Pressed"
            case .avatarPressed:             return "ProfileView_Avatar_Pressed"
            case .deleteAvatarStart:         return "ProfileView_DeleteAvatar_Start"
            case .deleteAvatarSuccess:       return "ProfileView_DeleteAvatar_Success"
            case .deleteAvatarFail:          return "ProfileView_DeleteAvatar_Fail"
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsSuccess(count: let count):
                return [
                    "avatars_count": count
                ]
            case .loadAvatarsFail(error: let error), .deleteAvatarFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar), .deleteAvatarStart(avatar: let avatar), .deleteAvatarSuccess(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarsFail, .deleteAvatarFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

struct ProfileView: View {
    
    @State var viewModel: ProfileViewModel

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                myInfoSection
                myAvatarsSection
            }
            .navigationTitle("Profile")
            .navigationDestinationForCoreModule(path: $viewModel.path)
            .showCustomAlert(alert: $viewModel.showAlert)
            .screenAppearAnalytics(name: "ProfileView")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                }
            }
        }
        .sheet(isPresented: $viewModel.showSettingsView) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $viewModel.showCreateAvatarView, onDismiss: {
            Task {
                await viewModel.loadData()
            }
        }, content: {
            CreateAvatarView()
        })
        .task {
            await viewModel.loadData()
        }
    }

    private var myInfoSection: some View {
        Section {
            ZStack {
                Circle()
                    .fill(viewModel.currentUser?.profileColorCalculated ?? .accent)
            }
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity)
            .removeListRowFormatting()
        }
    }

    private var myAvatarsSection: some View {
        Section {
            if viewModel.myAvatars.isEmpty {
                Group {
                    if viewModel.isLoading {
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
            ForEach(viewModel.myAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: nil
                )
                .anyButton(.highlight, action: {
                    viewModel.onAvatarPressed(avatar: avatar)
                })
                .removeListRowFormatting()
            }
            .onDelete { indexSet in
                viewModel.onDeleteAvatar(indexSet: indexSet)
            }
        } header: {
            HStack(spacing: 0) {
                Text("My avatars")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(.accent)
                    .anyButton {
                        viewModel.onNewAvatarButtonPressed()
                    }
            }
        }
    }

    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                viewModel.onSettingsButtonPressed()
            }
    }
}

#Preview {
    ProfileView(
        viewModel: ProfileViewModel(
            authManager: DevPreview.shared.authManager,
            userManager: DevPreview.shared.userManager,
            avatarManager: DevPreview.shared.avatarManager,
            logManager: DevPreview.shared.logManager
        )
    )
}
