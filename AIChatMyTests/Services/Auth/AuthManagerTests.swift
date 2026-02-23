//
//  AuthManagerTests.swift
//  AIChatMyTests
//
//  Created by Michal Fereniec on 23/02/2026.
//

import Testing
import SwiftUI
@testable import AIChat

@MainActor
struct AuthManagerTests {
    
    @Test("Initialization with Authenticated User")
    func testInitializationWithAuthenticatedUser() async throws {
        let mockUser = UserAuthInfo.mock(isAnonymous: false)
        let authService = MockAuthService(user: mockUser)
        let logManager = LogManager(services: [MockLogService()])

        let authManager = AuthManager(service: authService, logManager: logManager)
        
        #expect(authManager.auth?.uid == mockUser.uid)
    }
    
    @Test("Initialization with Non-Authenticated User")
    func testInitializationWithNonAuthenticatedUser() async throws {
        let authService = MockAuthService(user: nil)  // No user provided
        let logManager = LogManager(services: [MockLogService()])

        let authManager = AuthManager(service: authService, logManager: logManager)
        
        #expect(authManager.auth == nil)
    }
    
    @Test("Sign In Anonymously")
    func testSignInAnonymously() async throws {
        let authService = MockAuthService()
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])

        let authManager = AuthManager(service: authService, logManager: logManager)
        let result = try await authManager.signInAnonymously()
        
        #expect(result.user.isAnonymous == true)
        #expect(authManager.auth?.isAnonymous == true)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == AuthManager.Event.authListenerStart.eventName })
    }
    
    @Test("Sign In with Apple")
    func testSignInApple() async throws {
        let authService = MockAuthService()
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])

        let authManager = AuthManager(service: authService, logManager: logManager)
        let result = try await authManager.signInApple()
        
        #expect(result.user.isAnonymous == false)
        #expect(authManager.auth?.isAnonymous == false)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == AuthManager.Event.authListenerStart.eventName })
    }
    
    @Test("Sign Out")
    func testSignOut() throws {
        let mockUser = UserAuthInfo.mock(isAnonymous: false)
        let authService = MockAuthService(user: mockUser)
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])

        let authManager = AuthManager(service: authService, logManager: logManager)
        
        try authManager.signOut()
        
        #expect(authManager.auth == nil)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == AuthManager.Event.signOutStart.eventName })
        #expect(mockLogService.trackedEvents.contains { $0.eventName == AuthManager.Event.signOutSuccess.eventName })
    }
    
    @Test("Delete Account")
    func testDeleteAccount() async throws {
        let mockUser = UserAuthInfo.mock(isAnonymous: false)
        let authService = MockAuthService(user: mockUser)
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])

        let authManager = AuthManager(service: authService, logManager: logManager)
        
        try await authManager.deleteAccount()
        
        #expect(authManager.auth == nil)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == AuthManager.Event.deleteAccountStart.eventName })
        #expect(mockLogService.trackedEvents.contains { $0.eventName == AuthManager.Event.deleteAccountSuccess.eventName })
    }
}
