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
                    .environment(delegate.userManager)
                    .environment(delegate.authManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var authManager: AuthManager! // in this case `!` means we sure want to create and set auth and user manager BEFORE we want to fetch and get value
    var userManager: UserManager!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
    
        authManager = AuthManager(service: FirebaseAuthService())
        userManager = UserManager(services: ProductionUserServices())

    return true
  }
}
