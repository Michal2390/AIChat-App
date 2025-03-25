//
//  AppView.swift
//  AIChat
//
//  Created by Michal Fereniec on 13/01/2025.
//

import SwiftUI

struct AppView: View {
    
    @Environment(AuthManager.self) private var authManager

    @State var appState: AppState = AppState()
    
    var body: some View {
        AppViewBuilder(
            showTabBar: appState.showTabbar,
            tabbarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView()
            }
        )
        .environment(appState)
        .task {
            await checkUserStatus()
        }
        .onChange(of: appState.showTabbar) { _, showTabBar in
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
            }
        }
    }
    
    private func checkUserStatus() async {
        if let user = authManager.auth {
            // user is authenticated
            print("User already authenticated: \(user.uid)")
        } else {
            // user is not authenticated
            
            do {
                let result = try await authManager.signInAnynomously()
                
                // log in to app
                print("Sign in anonymous success: \(result.user.uid)")
            } catch {
                print(error)
            }
        }
    }
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabbar: true))
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabbar: false))
}
