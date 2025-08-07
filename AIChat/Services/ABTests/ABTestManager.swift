//
//  ABTestManager.swift
//  AIChat
//
//  Created by Michal Fereniec on 06/08/2025.
//
import SwiftUI

struct ActiveABTests: Codable {
    private(set) var createAccountTest: Bool // I want to mutate it only within the struct
    private(set) var onboardingCommunityTest: Bool
    
    init(createAccountTest: Bool, onboardingCommunityTest: Bool) {
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202508_CreateAccTest"
        case onboardingCommunityTest = "_202508_OnbCommunityTest"
    }
    
    var eventParameters: [String: Any] {
        let dictionary: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest
        ]
        return dictionary.compactMapValues({ $0 })
    }
    
    mutating func update(createAccountTest newValue: Bool) {
        createAccountTest = newValue
    }
    
    mutating func update(onboardingCommunityTest newValue: Bool) {
        onboardingCommunityTest = newValue
    }
}

protocol ABTestService {
    var activeTests: ActiveABTests { get }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws
}

class MockABTestService: ABTestService {
    
    var activeTests: ActiveABTests
    
    init(createAccountTest: Bool? = nil, onboardingCommunityTest: Bool? = nil) {
        self.activeTests = ActiveABTests(
            createAccountTest: createAccountTest ?? false,
            onboardingCommunityTest: onboardingCommunityTest ?? false
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        activeTests = updatedTests
    }
    
}

class LocalABTestService: ABTestService {
    
    @UserDefault(key: ActiveABTests.CodingKeys.createAccountTest.rawValue, startingValue: .random())
    private var createAccountTest: Bool
    
    @UserDefault(key: ActiveABTests.CodingKeys.onboardingCommunityTest.rawValue, startingValue: .random())
    private var onboardingCommunityTest: Bool
    
    var activeTests: ActiveABTests {
        ActiveABTests(
            createAccountTest: createAccountTest,
            onboardingCommunityTest: onboardingCommunityTest
        )
    }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        createAccountTest = updatedTests.createAccountTest
        onboardingCommunityTest = updatedTests.onboardingCommunityTest
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
        activeTests = service.activeTests
        logMaanger?.addUserProperties(dict: activeTests.eventParameters, isHighPriority: false)
    }
    
    func override(updatedTests: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTests: updatedTests)
        configure()
    }
    
}
