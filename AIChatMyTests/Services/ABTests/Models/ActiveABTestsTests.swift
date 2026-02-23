//
//  ActiveABTestsTests.swift
//  AIChatMyTests
//
//  Created by Michal Fereniec on 23/02/2026.
//

import Testing
import SwiftUI
@testable import AIChat

@MainActor
struct ActiveABTestsTests {

    @Test("MockABTestService Initialization")
    func testMockABTestServiceInitialization() async throws {
        let randomCreateAccountTest = Bool.random
        let randomOnboardingCommunityTest = Bool.random
        let randomCategoryRowTest = CategoryRowTestOption.allCases.randomElement() ?? .default
        let randomPaywallTest = PaywallTestOption.allCases.randomElement() ?? .default
        
        let mockService = MockABTestService(
            createAccountTest: randomCreateAccountTest,
            onboardingCommunityTest: randomOnboardingCommunityTest,
            categoryRowTest: randomCategoryRowTest,
            paywallTest: randomPaywallTest
        )
        
        #expect(mockService.activeTests.createAccountTest == randomCreateAccountTest)
        #expect(mockService.activeTests.onboardingCommunityTest == randomOnboardingCommunityTest)
        #expect(mockService.activeTests.categoryRowTest == randomCategoryRowTest)
        #expect(mockService.activeTests.paywallTest == randomPaywallTest)
    }

    @Test("MockABTestService Save Updated Config")
    func testSaveUpdatedConfig() async throws {
        let mockService = MockABTestService()
        
        let newCreateAccountTest = Bool.random
        let newOnboardingCommunityTest = Bool.random
        let newCategoryRowTest = CategoryRowTestOption.allCases.randomElement() ?? .default
        let newPaywallTest = PaywallTestOption.allCases.randomElement() ?? .default
        
        let updatedTests = ActiveABTests(
            createAccountTest: newCreateAccountTest,
            onboardingCommunityTest: newOnboardingCommunityTest,
            categoryRowTest: newCategoryRowTest,
            paywallTest: newPaywallTest
        )
        
        try mockService.saveUpdatedConfig(updatedTests: updatedTests)
        
        #expect(mockService.activeTests.createAccountTest == newCreateAccountTest)
        #expect(mockService.activeTests.onboardingCommunityTest == newOnboardingCommunityTest)
        #expect(mockService.activeTests.categoryRowTest == newCategoryRowTest)
        #expect(mockService.activeTests.paywallTest == newPaywallTest)
    }

    @Test("MockABTestService Fetch Updated Config")
    func testFetchUpdatedConfig() async throws {
        let initialCreateAccountTest = Bool.random
        let initialOnboardingCommunityTest = Bool.random
        let initialCategoryRowTest = CategoryRowTestOption.allCases.randomElement() ?? .default
        let initialPaywallTest = PaywallTestOption.allCases.randomElement() ?? .default
        
        let mockService = MockABTestService(
            createAccountTest: initialCreateAccountTest,
            onboardingCommunityTest: initialOnboardingCommunityTest,
            categoryRowTest: initialCategoryRowTest,
            paywallTest: initialPaywallTest
        )
        
        let fetchedConfig = try await mockService.fetchUpdatedConfig()
        
        #expect(fetchedConfig.createAccountTest == initialCreateAccountTest)
        #expect(fetchedConfig.onboardingCommunityTest == initialOnboardingCommunityTest)
        #expect(fetchedConfig.categoryRowTest == initialCategoryRowTest)
        #expect(fetchedConfig.paywallTest == initialPaywallTest)
    }

    @Test("ActiveABTests Event Parameters")
    func testEventParameters() async throws {
        let randomCreateAccountTest = Bool.random
        let randomOnboardingCommunityTest = Bool.random
        let randomCategoryRowTest = CategoryRowTestOption.allCases.randomElement() ?? .default
        let randomPaywallTest = PaywallTestOption.allCases.randomElement() ?? .default
        
        let activeABTests = ActiveABTests(
            createAccountTest: randomCreateAccountTest,
            onboardingCommunityTest: randomOnboardingCommunityTest,
            categoryRowTest: randomCategoryRowTest,
            paywallTest: randomPaywallTest
        )
        
        let params = activeABTests.eventParameters
        #expect(params["test_202508_CreateAccTest"] as? Bool == randomCreateAccountTest)
        #expect(params["test_202508_OnbCommunityTest"] as? Bool == randomOnboardingCommunityTest)
        #expect(params["test_202508_CategoryRowTest"] as? String == randomCategoryRowTest.rawValue)
        #expect(params["test_202502_PaywallTest"] as? String == randomPaywallTest.rawValue)
    }

    @Test("ActiveABTests Codable Conformance")
    func testCodableConformance() async throws {
        let randomCreateAccountTest = Bool.random
        let randomOnboardingCommunityTest = Bool.random
        let randomCategoryRowTest = CategoryRowTestOption.allCases.randomElement() ?? .default
        let randomPaywallTest = PaywallTestOption.allCases.randomElement() ?? .default
        
        let originalTests = ActiveABTests(
            createAccountTest: randomCreateAccountTest,
            onboardingCommunityTest: randomOnboardingCommunityTest,
            categoryRowTest: randomCategoryRowTest,
            paywallTest: randomPaywallTest
        )
        
        // Encode ActiveABTests to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalTests)
        
        // Decode JSON back to ActiveABTests
        let decoder = JSONDecoder()
        let decodedTests = try decoder.decode(ActiveABTests.self, from: data)
        
        // Assert that all properties are equal
        #expect(decodedTests.createAccountTest == originalTests.createAccountTest)
        #expect(decodedTests.onboardingCommunityTest == originalTests.onboardingCommunityTest)
        #expect(decodedTests.categoryRowTest == originalTests.categoryRowTest)
        #expect(decodedTests.paywallTest == originalTests.paywallTest)
    }
}
