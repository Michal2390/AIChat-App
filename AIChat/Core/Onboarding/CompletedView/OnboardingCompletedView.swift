//
//  OnboardingCompletedView.swift
//  AIChat
//
//  Created by Michal Fereniec on 16/01/2025.
//

import SwiftUI

struct OnboardingCompletedView: View {

    @Environment(AppState.self) private var root
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager

    @State private var isCompletingProfileSetup: Bool = false
    var selectedColor: Color = .orange
    @State private var showAlert: AnyAppAlert?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup complete!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor)

            Text("We've set up your profile and you're ready to start chatting.")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: {
                AsyncCallToActionButton(
                    isLoading: isCompletingProfileSetup,
                    title: "Finish",
                    action: onFinishButtonPressed
                )
        })
        .padding(24)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCompletedView")
        .showCustomAlert(alert: $showAlert)
    }

    enum Event: LoggableEvent {
        case finishStart
        case finishSuccess(hex: String)
        case finishFail(error: Error)
        
        var eventName: String {
            switch self {
                
            case .finishStart:           return "OnboardingCompletedView_Finish_Start"
            case .finishSuccess:         return "OnboardingCompletedView_Finish_Success"
            case .finishFail:            return "OnboardingCompletedView_Finish_Fail"
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case .finishSuccess(hex: let hex):
                return [
                    "profile_color_hex": hex
                ]
            case .finishFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .finishFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    func onFinishButtonPressed() {
        isCompletingProfileSetup = true
        logManager.trackEvent(event: Event.finishStart)
        
        Task {
            do {
                let hex = selectedColor.asHex()
                try await userManager.markOnboardingCompleteForCurrentUser(profileColorHex: hex)
                logManager.trackEvent(event: Event.finishSuccess(hex: hex))

                // dismiss screen
                isCompletingProfileSetup = false
                root.updateViewState(showTabBarView: true)
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.finishFail(error: error))
            }
        }
    }
}

#Preview {
    OnboardingCompletedView(selectedColor: .mint)
        .environment(UserManager(services: MockUserServices()))
        .environment(AppState())
}
