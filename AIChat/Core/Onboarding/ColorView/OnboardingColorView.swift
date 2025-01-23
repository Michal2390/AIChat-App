//
//  OnboardingColorView.swift
//  AIChat
//
//  Created by Michal Fereniec on 20/01/2025.
//

import SwiftUI

struct OnboardingColorView: View {
    
    @State private var selectedColor: Color?
    let profileColors: [Color] = [.red, .green, .cyan, .blue, .yellow, .orange, .pink, .purple, .gray, .black, .indigo, .mint, .teal, .brown]
    var body: some View {
        ScrollView {
            colorGrid
            .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 10, content: {
            ZStack {
                if let selectedColor {
                    ctaButton(selectedColor: selectedColor)
                    .transition(AnyTransition.move(edge: .bottom).animation(.bouncy))
                }
            }
            .padding(10)
            .background(Color(uiColor: .systemBackground)) // this way we support light & dark mode
        })
        .animation(.bouncy, value: selectedColor)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private var colorGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
            alignment: .center,
            spacing: 16,
            pinnedViews: .sectionHeaders,
            content: {
                Section {
                    ForEach(profileColors, id: \.self) { color in
                        Circle()
                            .fill(.accent)
                            .overlay(
                                color
                                    .clipShape(Circle())
                                    .padding(selectedColor == color ? 10 : 0)
                            )
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                } header: {
                    Text("Select a profile color")
                        .font(.headline)
                }

            }
        )
    }
    
    private func ctaButton(selectedColor: Color) -> some View {
        NavigationLink {
            OnboardingCompletedView(selectedColor: selectedColor)
        } label: {
            Text("Continue")
                .callToActionButton()
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingColorView()
    }
    .environment(AppState())
}
