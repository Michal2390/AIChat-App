//
//  ABTestManager.swift
//  AIChat
//
//  Created by Michal Fereniec on 06/08/2025.
//
import SwiftUI

struct ActiveABTests: Codable {
    let createAccountTest: Bool
    
    init(createAccountTest: Bool) {
        self.createAccountTest = createAccountTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202508_CreateAccTest"
    }
    
    var eventParameters: [String: Any] {
        let dictionary: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest
        ]
        return dictionary.compactMapValues({ $0 })
    }
}

protocol ABTestService {
    var activeTests: ActiveABTests { get }
}

struct MockABTestService: ABTestService {
    
    let activeTests: ActiveABTests
    
    init(createAccountTest: Bool? = nil) {
        self.activeTests = ActiveABTests(
            createAccountTest: createAccountTest ?? false)
    }
    
}

@MainActor
@Observable
class ABTestManager {
    
    private let service: ABTestService
    private let logMaanger: LogManager?
    var activeTests: ActiveABTests
    
    init(service: ABTestService, logManager: LogManager? = nil) {
        self.logMaanger = logManager
        self.service = service
        self.activeTests = service.activeTests
        self.configure()
    }
    
    private func configure() {
        logMaanger?.addUserProperties(dict: activeTests.eventParameters, isHighPriority: false)
    }
    
}
