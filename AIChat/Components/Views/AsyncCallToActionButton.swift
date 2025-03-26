//
//  AsyncCallToActionButton.swift
//  AIChat
//
//  Created by Michal Fereniec on 19/02/2025.
//
import SwiftUI

struct AsyncCallToActionButton: View {

    var isLoading: Bool = false
    var title: String = "Save"
    var action: () -> Void

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(title)
            }
        }
        .callToActionButton()
        .anyButton(.press) {
            Task {
                action()
            }
        }
        .disabled(isLoading) // to not cause potential bug by saving many times to the database
    }
}

private struct PreviewView: View {

    @State private var isLoading: Bool = false

    var body: some View {
        AsyncCallToActionButton(
            isLoading: isLoading,
            title: "Finish") {
                isLoading = true

                Task {
                    try? await Task.sleep(for: .seconds(3))
                    isLoading = false
                }
            }
    }
}

#Preview {
    PreviewView()
        .padding()
}
