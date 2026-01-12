//
//  AppView.swift
//  AIChat
//
//  Created by Michal Fereniec on 13/01/2025.
//

import SwiftUI
import SwiftfulUtilities

struct AppView: View {

    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(PurchaseManager.self) private var purchaseManager
    
    @State var appState: AppState = AppState()

    var body: some View {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task {
                        await checkUserStatus()
                    }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: nil,
                onApplicationWillTerminate: nil
            )) {
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
                .onNotificationReceived(name: UIApplication.willEnterForegroundNotification, action: { _ in
                    Task {
                        await checkUserStatus()
                    }
                })
                .task {
                    try? await Task.sleep(for: .seconds(2))
                    await showATTPromptIfNeeded()
                }
                .onChange(of: appState.showTabbar) { _, showTabBar in
                    if !showTabBar {
                        Task {
                            await checkUserStatus()
                        }
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
        case attStatus(dict: [String: Any])
        
        var eventName: String {
            switch self {
            case .existingAuthStart:        return "AppView_ExistingAuth_Start"
            case .existingAuthFail:         return "AppView_ExistingAuth_Fail"
            case .anonAuthStart:            return "AppView_AnonAuth_Start"
            case .anonAuthSuccess:          return "AppView_AnonAuth_Success"
            case .anonAuthFail:             return "AppView_AnonAuth_Fail"
            case .attStatus:                return "AppView_ATTStatus"
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonAuthFail(error: let error):
                return error.eventParameters
            case .attStatus(dict: let dict):
                return dict
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
    
    private func showATTPromptIfNeeded() async {
        #if !DEBUG
        let status = await AppTrackingTransparencyHelper.requestTrackingAuthorization()
        logManager.trackEvent(event: Event.attStatus(dict: status.eventParameters))
        #endif
    }

    private func checkUserStatus() async {
        if let user = authManager.auth {
            // user is authenticated
            logManager.trackEvent(event: Event.existingAuthStart)

            do {
                try await userManager.logIn(auth: user, isNewUser: false)
                try await purchaseManager.logIn(
                    userId: user.uid,
                    attributes: PurchaseProfileAttributes(
                        email: user.email,
                        firebaseAppInstanceId: FirebaseAnalyticsService.appInstanceId
                    )
                )
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
                try await purchaseManager.logIn(
                    userId: result.user.uid,
                    attributes: PurchaseProfileAttributes(firebaseAppInstanceId: FirebaseAnalyticsService.appInstanceId)
                )
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
