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
        .onAppear {
            logManager.identifyUser(userId: "bydlak123", name: "Ziom", email: "KochamFistaszki@blabla.com")
            logManager.addUserProperties(dict: UserModel.mock.eventParameters, isHighPriority: false)
            
            logManager.trackEvent(event: Event.alpha)
            logManager.trackEvent(event: Event.beta)
            logManager.trackEvent(event: Event.gamma)
            logManager.trackEvent(event: Event.delta)
            
            let event = AnyLoggableEvent(
                eventName: "MyNewEvent",
                parameters: UserModel.mock.eventParameters,
                type: .analytic
            )
            logManager.trackEvent(event: event)

            logManager.trackEvent(eventName: "AnotherEventMyG!")
        }
        .onChange(of: appState.showTabbar) { _, showTabBar in
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
            }
        }
    }
    
    enum Event: LoggableEvent {
        case alpha, beta, gamma, delta
        
        var eventName: String {
            switch self {
            case .alpha:
                return "Event_Alpha"
            case .beta:
                return "Event_Beta"
            case .gamma:
                return "Event_Gamma"
            case .delta:
                return "Event_Delta"
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case .alpha, .beta:
                return [
                    "aaa": true,
                    "bbb": 123
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .alpha:
                return .info
            case .beta:
                return .analytic
            case .gamma:
                return .warning
            case .delta:
                return .severe
            }
        }
    }

    private func checkUserStatus() async {
        if let user = authManager.auth {
            // user is authenticated
            print("User already authenticated: \(user.uid)")

            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                print("Failed to log in to auth for exisitng user: \(error)")
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            // user is not authenticated

            do {
                let result = try await authManager.signInAnynomously()

                // log in to app
                print("Sign in anonymous success: \(result.user.uid)")

                // Log in
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                print("Failed to sign in anonymously and log in: \(error)")
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
