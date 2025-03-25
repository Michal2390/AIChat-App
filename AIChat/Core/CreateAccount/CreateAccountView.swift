//
//  CreateAccountView.swift
//  AIChat
//
//  Created by Michal Fereniec on 18/02/2025.
//

import SwiftUI

struct CreateAccountView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager

    var title: String = "Create Account?"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.body)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            SignInWithAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: 30
            )
                .frame(height: 50)
                .anyButton(.press) {
                     
                }
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
    }
    
    func onSignInApplePressed() {
        Task {
            do {
                let result = try await authManager.signInApple()
                onDidSignIn?(result.isNewUser)
                print("Did sign in with apple broski!")
                dismiss()
            } catch {
                print("Error signing in with Apple :(")
            }
        }
    }
}

#Preview {
    CreateAccountView()
}
