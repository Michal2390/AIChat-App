//
//  AIChatApp.swift
//  AIChat
//
//  Created by Michal Fereniec on 09/01/2025.
//

import SwiftUI
import Firebase

@main
struct AIChatApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
                AppView()
                    .environment(delegate.dependencies.chatManager)
                    .environment(delegate.dependencies.aiManager)
                    .environment(delegate.dependencies.avatarManager)
                    .environment(delegate.dependencies.userManager)
                    .environment(delegate.dependencies.authManager) // putting AUTH the lowest to be sure its the parent most dependency as it is the most important one
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies! // in this case `!` means we sure want to create and set our dependencies BEFORE we want to fetch and get value
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        dependencies = Dependencies()

    return true
  }
}

@MainActor
struct Dependencies {
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    
    init() {
        authManager = AuthManager(service: FirebaseAuthService())
        userManager = UserManager(services: ProductionUserServices())
        aiManager = AIManager(service: OpenAIService())
        avatarManager = AvatarManager(remote: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
        chatManager = ChatManager(service: FirebaseChatService())
    }
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(ChatManager(service: MockChatService()))
            .environment(AIManager(service: MockAIService()))
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil)))
            .environment(AvatarManager(remote: MockAvatarService(), local: MockLocalAvatarPersistence()))
            .environment(AppState())
    }
}
