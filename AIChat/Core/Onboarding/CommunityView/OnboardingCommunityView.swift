//
//  OnboardingCommunityView.swift
//  AIChat
//
//  Created by Michal Fereniec on 07/08/2025.
//

import SwiftUI

struct OnboardingCommunityView: View {
    var body: some View {
        VStack {
            Group {
                VStack(spacing: 40) {
                    ImageLoaderView()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                    
                    Text("Join our community with over ")
                    +
                    Text("1000+ ")
                        .foregroundStyle(.accent)
                        .fontWeight(.semibold)
                    +
                    Text("custom avatars.\n\nAsk them questions or have a casual conversation! ")
                        .foregroundStyle(.accent)
                        .fontWeight(.semibold)
                }
                .baselineOffset(6) // spacing between successive lines
                .minimumScaleFactor(0.5)
                .padding(24)
            }
            .frame(maxHeight: .infinity)
            
            NavigationLink {
                OnboardingColorView()
            } label: {
                Text("Continue")
                    .callToActionButton()
            }
        }
        .font(.title3)
        .padding(24)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCommunityView")
    }
}

#Preview {
    NavigationStack {
        OnboardingCommunityView()
    }
    .previewEnvironment()
}
