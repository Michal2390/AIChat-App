//
//  OpenAIService.swift
//  AIChat
//
//  Created by Michal Fereniec on 26/03/2025.
//
import SwiftUI
import FirebaseFunctions

struct OpenAIService: AIService {

    func generateImage(input: String) async throws -> UIImage {
        let response = try await Functions.functions().httpsCallable("generateOpenAIImage").call([
            "input": input
        ])

        guard
            let b64Json = response.data as? String,
            let data = Data(base64Encoded: b64Json),
            let image = UIImage(data: data) else {
            throw OpenAIError.invalidResponse
        }

        return image
    }

    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        let messages = chats.compactMap { chat in
            let role = chat.role.rawValue
            let content = chat.message
            return [
                "role": role,
                "content": content
            ]
        }
        
        let response = try await Functions.functions().httpsCallable("generateOpenAIText").call([
            "messages": messages
        ])
        
        guard
            let dict = response.data as? [String: Any],
            let roleString = dict["role"] as? String,
            let role = AIChatRole(rawValue: roleString),
            let content = dict["content"] as? String else {
            throw OpenAIError.invalidResponse
        }
        
        return AIChatModel(role: role, content: content)
    }
    
    enum OpenAIError: LocalizedError {
        case invalidResponse
    }

}

struct AIChatModel: Codable {
    let role: AIChatRole
    let message: String

    init(role: AIChatRole, content: String) {
        self.role = role
        self.message = content
    }
    
    enum CodingKeys: String, CodingKey {
        case role
        case message
    }

    var eventParameters: [String: Any] {
        let dictionary: [String: Any?] = [
            "aichat_\(CodingKeys.role.rawValue)": role.rawValue,
            "aichat_\(CodingKeys.message.rawValue)": message
        ]
        return dictionary.compactMapValues({ $0 })
    }
}

enum AIChatRole: String, Codable {
    case user, assistant, system, tool
}

/*
 public var role: Role { get {
     switch self {
     case .system(let systemMessage):
         return systemMessage.role
     case .developer(let developerMessage):
         return developerMessage.role
     case .user(let userMessage):
         return userMessage.role
     case .assistant(let assistantMessage):
         return assistantMessage.role
     case .tool(let toolMessage):
         return toolMessage.role
     }
 }}

 
 
 */
