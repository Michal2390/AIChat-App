//
//  SettingsView.swift
//  AIChat
//
//  Created by Michal Fereniec on 16/01/2025.
//

import SwiftUI

struct SettingsView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AppState.self) private var appState
    @Environment(LogManager.self) private var logManager

    @State private var isPremium: Bool = false
    @State private var isAnonymousUser: Bool = false
    @State private var showCreateAccountView: Bool = false
    @State private var showAlert: AnyAppAlert?

    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchasesSection
                applicationSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showCreateAccountView, onDismiss: {
                setAnonymousAccountStatus()
            }, content: {
                CreateAccountView()
                    .presentationDetents([.medium])
            })
            .onAppear {
                setAnonymousAccountStatus()
            }
            .showCustomAlert(alert: $showAlert)
            .screenAppearAnalytics(name: "SettingsView")
        }
    }

    private var accountSection: some View {
        Section {
            if isAnonymousUser {
                Text("Save & back-up account")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onCreateAccountPressed()
                    }
                    .removeListRowFormatting()
            } else {
                Text("Sign out")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onSignOutPressed()
                    }
                    .removeListRowFormatting()
            }
            Text("Delete account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    onDeleteAccountPressed()
                }
                .removeListRowFormatting()
        } header: {
            Text("Account")
        }

    }

    private var purchasesSection: some View {
        Section {
            HStack(spacing: 8) {
                Text("Account status: \(isPremium ? "Premium" : "FREE")")
                Spacer(minLength: 0)
                if isPremium {
                    Text("MANAGE")
                        .badgeButton()
                }
            }
                .rowFormatting()
                .anyButton(.highlight) {

                }
                .disabled(!isPremium)
                .removeListRowFormatting()
        } header: {
            Text("Purchases")
        }
    }

    private var applicationSection: some View {
        Section {
            HStack(spacing: 8) {
                Text("Version")
                Spacer(minLength: 0)
                Text(Utilities.appVersion ?? "")
                    .foregroundStyle(.secondary)
            }
                .rowFormatting()
                .removeListRowFormatting()

            HStack(spacing: 8) {
                Text("Build Number")
                Spacer(minLength: 0)
                Text(Utilities.buildNumber ?? "")
                    .foregroundStyle(.secondary)
            }
                .rowFormatting()
                .removeListRowFormatting()

            Text("Contact us")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight, action: {

                })
                .removeListRowFormatting()
        } header: {
            Text("Application")
        } footer: {
            Text("Created by Michał Fereniec.\nLearn more @ https://github.com/Michal2390/AIChat-App")
                .baselineOffset(4)
        }
    }

    func setAnonymousAccountStatus() {
        isAnonymousUser = authManager.auth?.isAnonymous == true
    }

    enum Event: LoggableEvent {
        case signOutStart
        case signOutSuccess
        case signOutFail(error: Error)
        case createAccountPressed
        case deleteAccountConfirm
        case deleteAccountStart
        case deleteAccountSuccess
        case deleteAccountFail(error: Error)
        
        var eventName: String {
            switch self {
            case .signOutStart:             return "SettingsView_SignOut_Start"
            case .signOutSuccess:           return "SettingsView_SignOut_Success"
            case .signOutFail:              return "SettingsView_SignOut_Fail"
            case .createAccountPressed:     return "SettingsView_CreateAccount_Pressed"
            case .deleteAccountConfirm:     return "SettingsView_DeleteAccount_Confirm"
            case .deleteAccountStart:       return "SettingsView_DeleteAccount_Start"
            case .deleteAccountSuccess:     return "SettingsView_DeleteAccount_Success"
            case .deleteAccountFail:        return "SettingsView_DeleteAccount_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(error: let error), .deleteAccountFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .signOutFail, .deleteAccountFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    func onSignOutPressed() {
        logManager.trackEvent(event: Event.signOutStart)
        
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                logManager.trackEvent(event: Event.signOutSuccess)
                
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.signOutFail(error: error))
            }

        }
    }

    private func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(1))
        appState.updateViewState(showTabBarView: false)
    }

    func onDeleteAccountPressed() {
        logManager.trackEvent(event: Event.deleteAccountConfirm)

        showAlert = AnyAppAlert(
            title: "Delete account?",
            subtitle: "This action is permament and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive) {
                        onDeleteAccountConfirmed()
                    }
                )
            }
        )
    }

    private func onDeleteAccountConfirmed() {
        logManager.trackEvent(event: Event.deleteAccountStart)
        
        Task {
            do {
                let uid = try authManager.getAuthId()
                async let deleteAuth: () = authManager.deleteAccount()
                async let deleteUser: () = userManager.deleteCurrentUser()
                async let deleteAvatars: () = avatarManager.removeAuthorIdFromAllUserAvatars(userId: uid)
                async let deleteChats: () = chatManager.deleteAllChatsForUser(userId: uid)

                let (_, _, _, _) = await (try deleteAuth, try deleteUser, try deleteAvatars, try deleteChats)
                logManager.deleteUserProfile()
                logManager.trackEvent(event: Event.deleteAccountSuccess)
                
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.deleteAccountFail(error: error))
            }

        }
    }

    func onCreateAccountPressed() {
        showCreateAccountView = true
        logManager.trackEvent(event: Event.createAccountPressed)
    }
}

fileprivate extension View {

    func rowFormatting() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(uiColor: .systemBackground))
    }
}

#Preview("No Auth") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .previewEnvironment()
}

#Preview("Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvironment()
}

#Preview("Not Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvironment()
}
