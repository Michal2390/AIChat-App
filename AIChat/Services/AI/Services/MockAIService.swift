//
//  MockAIService.swift
//  AIChat
//
//  Created by Michal Fereniec on 26/03/2025.
//
import SwiftUI

struct MockAIService: AIService {
    
    let delay: Double
    let showError: Bool
    
    init(delay: Double = 0.0, showError: Bool = false) {
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func generateImage(input: String) async throws -> UIImage {
        try await Task.sleep(for: .seconds(3))
        try tryShowError()
        return UIImage(systemName: "star.fill")!
    }

    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await Task.sleep(for: .seconds(2))
        try tryShowError()
        return AIChatModel(role: .assistant, content: "This is returned text from the AI my nigga!!!")
    }
}
