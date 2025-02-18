//
//  CreateAccountView.swift
//  AIChat
//
//  Created by Michal Fereniec on 18/02/2025.
//

import SwiftUI

struct CreateAccountView: View {
    
    var title: String = "Create Account?"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
    
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
}

#Preview {
    CreateAccountView()
}
