//
//  AppView.swift
//  AIChat
//
//  Created by Michal Fereniec on 13/01/2025.
//

import SwiftUI

struct AppView: View {

    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
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
        .screenAppearAnalytics(name: "AppView")
        .onChange(of: appState.showTabbar) { _, showTabBar in
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
            }
        }
    }
    
    enum Event: LoggableEvent {
        case existingAuthStart
        case existingAuthFail(error: Error)
        case anonAuthStart
        case anonAuthSuccess
        case anonAuthFail(error: Error)
        
        var eventName: String {
            switch self {
            case .existingAuthStart:        return "AppView_ExistingAuth_Start"
            case .existingAuthFail:         return "AppView_ExistingAuth_Fail"
            case .anonAuthStart:            return "AppView_AnonAuth_Start"
            case .anonAuthSuccess:          return "AppView_AnonAuth_Success"
            case .anonAuthFail:             return "AppView_AnonAuth_Fail"

            }
        }
        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonAuthFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .existingAuthFail, .anonAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }

    private func checkUserStatus() async {
        if let user = authManager.auth {
            // user is authenticated
            logManager.trackEvent(event: Event.existingAuthStart)

            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                logManager.trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            // user is not authenticated
            logManager.trackEvent(event: Event.anonAuthStart)

            do {
                let result = try await authManager.signInAnynomously()

                // log in to app
                logManager.trackEvent(event: Event.anonAuthSuccess)

                // Log in
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                logManager.trackEvent(event: Event.anonAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabbar: true))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AuthManager(service: MockAuthService(user: .mock())))

}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabbar: false))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
}
