//
//  ActiveABTests.swift
//  AIChat
//
//  Created by Michal Fereniec on 08/08/2025.
//
import SwiftUI

struct ActiveABTests: Codable {
    private(set) var createAccountTest: Bool // I want to mutate it only within the struct
    private(set) var onboardingCommunityTest: Bool
    private(set) var categoryRowTest: CategoryRowTestOption = .original
    
    init(
        createAccountTest: Bool,
        onboardingCommunityTest: Bool,
        categoryRowTest: CategoryRowTestOption
    ) {
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
        self.categoryRowTest = categoryRowTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202508_CreateAccTest"
        case onboardingCommunityTest = "_202508_OnbCommunityTest"
        case categoryRowTest = "_202508_CategoryRowTest"
    }
    
    var eventParameters: [String: Any] {
        let dictionary: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest,
            "test\(CodingKeys.categoryRowTest.rawValue)": categoryRowTest.rawValue // I want to send a String to analytics
        ]
        return dictionary.compactMapValues({ $0 })
    }
    
    mutating func update(createAccountTest newValue: Bool) {
        createAccountTest = newValue
    }
    
    mutating func update(onboardingCommunityTest newValue: Bool) {
        onboardingCommunityTest = newValue
    }
    
    mutating func update(categoryRowTest newValue: CategoryRowTestOption) {
        categoryRowTest = newValue
    }
}

// MARK: - REMOTE CONFIG

import FirebaseRemoteConfig

extension ActiveABTests {
    
    init(config: RemoteConfig) {
        let createAccountTest = config.configValue(forKey: ActiveABTests.CodingKeys.createAccountTest.rawValue).boolValue
        self.createAccountTest = createAccountTest
        
        let onboardingCommunityTest = config.configValue(forKey: ActiveABTests.CodingKeys.onboardingCommunityTest.rawValue).boolValue
        self.onboardingCommunityTest = onboardingCommunityTest
        
        let categoryRowTestStringValue = config.configValue(forKey: ActiveABTests.CodingKeys.categoryRowTest.rawValue).stringValue
        if let option = CategoryRowTestOption(rawValue: categoryRowTestStringValue) {
            self.categoryRowTest = option
        } else {
            self.categoryRowTest = .default
        }
    }
    
    // Converted to a NSObject dicitonary to setDefaults within FirebaseABTestService
    var asNSObjectDictionary: [String: NSObject]? {
        [
            CodingKeys.createAccountTest.rawValue: createAccountTest as NSObject,
            CodingKeys.onboardingCommunityTest.rawValue: onboardingCommunityTest as NSObject,
            CodingKeys.categoryRowTest.rawValue: categoryRowTest.rawValue as NSObject
        ]
    }
}
