//
//  WelcomeView.swift
//  AIChat
//
//  Created by Michal Fereniec on 13/01/2025.
//

import SwiftUI

struct WelcomeView: View {

    @Environment(AppState.self) private var root

    @State var imageName: String = Constants.randomImage
    @State private var showSignInView: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                ImageLoaderView(urlString: imageName)
                    .ignoresSafeArea()
                    .frame(height: 480)

                titleSection
                    .padding(.top, 24)

                ctaButtons
                    .padding(16)

                policyLinks
            }
        }
        .sheet(isPresented: $showSignInView) {
            CreateAccountView(
                title: "Sign in",
                subtitle: "Connect to an existing account",
                onDidSignIn: { isNewUser in
                    handleDidSignIn(isNewUser: isNewUser)
                }
            )
            .presentationDetents([.medium])
        }
    }

    private var titleSection: some View {
        VStack {
            Text(Constants.welcomeText)
                .frame(maxHeight: .infinity)
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text(Constants.welcomeName)
                .opacity(0.7)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var ctaButtons: some View {
        VStack(spacing: 8) {
            NavigationLink {
                OnboardingIntroView()
            } label: {
                Text("Get Started my G!")
                    .callToActionButton()
            }

            Text("Already have an account? Sign in.")
                .foregroundStyle(.black)
                .underline()
                .font(.body)
                .padding(8)
                .tappableBackground()
                .onTapGesture {
                    onSignInPressed()
                }
        }
    }

    private func handleDidSignIn(isNewUser: Bool) {
        if isNewUser {
            // Do nothing, user goes through onboarding
        } else {
            // Push into tabbar view
            root.updateViewState(showTabBarView: true)
        }
    }

    private func onSignInPressed() {
        showSignInView = true
    }

    private var policyLinks: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.termsOfServiceURL)!) {
                Text("Terms of Service")
            }
            Circle()
                .fill(.accent)
                .frame(width: 4, height: 4)
            Link(destination: URL(string: Constants.privacyPolicyURL)!) {
                Text("Privacy Policy")
            }
        }
    }
}

#Preview {
    WelcomeView()
}
