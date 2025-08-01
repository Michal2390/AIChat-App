//
//  OpenAIService.swift
//  AIChat
//
//  Created by Michal Fereniec on 26/03/2025.
//
import OpenAI
import SwiftUI
import FirebaseFunctions

private typealias ChatCompletion = ChatQuery.ChatCompletionMessageParam
private typealias SystemMessage = ChatQuery.ChatCompletionMessageParam.ChatCompletionSystemMessageParam
private typealias UserMessage = ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam
private typealias UserTextContent = ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam.Content
private typealias AssistantMessage = ChatQuery.ChatCompletionMessageParam.ChatCompletionAssistantMessageParam

struct OpenAIService: AIService {

    var openAI: OpenAI {
        OpenAI(apiToken: Keys.openAI)
    }

    func generateImage(input: String) async throws -> UIImage {
        let query = ImagesQuery(
            prompt: input,
            model: .gpt3_5Turbo,
            n: 1,
            // quality: .hd,
            responseFormat: .b64_json,
            size: ._512,
            // style: .natural,
            user: nil
        )

        let result = try await openAI.images(query: query)

        guard let b64Json = result.data.first?.b64Json,
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
    
    init?(chat: ChatResult.Choice.ChatCompletionMessage) {
        self.role = AIChatRole(role: chat.role)
        if let string = chat.content?.string {
            self.message = string
        } else {
            return nil
        }
    }
    
    fileprivate func toOpenAIModel() -> ChatCompletion? {
        switch role {
        case .user:
            return ChatCompletion.user(UserMessage(content: UserTextContent(string: message)))
        case .assistant:
            return ChatCompletion.assistant(AssistantMessage(content: message))
        case .system:
            return ChatCompletion.system(SystemMessage(content: message))
        case .tool:
            return nil
        }
    }
}

enum AIChatRole: String, Codable {
    case user, assistant, system, tool

    init(role: ChatQuery.ChatCompletionMessageParam.Role) {
        switch role {
        case .user:
            self = .system
        case .assistant:
            self = .assistant
        case .system:
            self = .system
        case .tool:
            self = .tool
        }
    }

    var openAIRole: ChatQuery.ChatCompletionMessageParam.Role {
        switch self {
        case .user:
            return .user
        case .assistant:
            return .assistant
        case .system:
            return .system
        case .tool:
            return .tool
        }
    }
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
