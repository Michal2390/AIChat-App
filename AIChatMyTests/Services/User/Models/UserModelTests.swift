//
//  UserModelTests.swift
//  AIChatMyTests
//
//  Created by Michal Fereniec on 23/02/2026.
//
import Testing
import SwiftUI
@testable import AIChat

struct UserModelTests {

    @Test("UserModel Initialization with Full Data")
    func testInitializationWithFullData() async throws {
        let randomUserId = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomIsAnonymous = Bool.random
        let randomCreationVersion = String.random
        let randomCreationDate = Date.random
        let randomLastSignInDate = Date.random
        let randomDidCompleteOnboarding = Bool.random
        let randomProfileColorHex = String.randomHexColor()
        
        let user = UserModel(
            userId: randomUserId,
            email: randomEmail,
            isAnonymous: randomIsAnonymous,
            creationDate: randomCreationDate,
            creationVersion: randomCreationVersion,
            lastSignInDate: randomLastSignInDate,
            didCompleteOnboarding: randomDidCompleteOnboarding,
            profileColorHex: randomProfileColorHex
        )
        
        #expect(user.userId == randomUserId)
        #expect(user.email == randomEmail)
        #expect(user.isAnonymous == randomIsAnonymous)
        #expect(user.creationDate == randomCreationDate)
        #expect(user.creationVersion == randomCreationVersion)
        #expect(user.lastSignInDate == randomLastSignInDate)
        #expect(user.didCompleteOnboarding == randomDidCompleteOnboarding)
        #expect(user.profileColorHex == randomProfileColorHex)
    }

    @Test("UserModel Event Parameters")
    func testEventParameters() async throws {
        let randomUserId = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomIsAnonymous = Bool.random
        let randomCreationVersion = String.random
        let randomCreationDate = Date.random
        let randomLastSignInDate = Date.random
        let randomDidCompleteOnboarding = Bool.random
        let randomProfileColorHex = String.randomHexColor()
        
        let user = UserModel(
            userId: randomUserId,
            email: randomEmail,
            isAnonymous: randomIsAnonymous,
            creationDate: randomCreationDate,
            creationVersion: randomCreationVersion,
            lastSignInDate: randomLastSignInDate,
            didCompleteOnboarding: randomDidCompleteOnboarding,
            profileColorHex: randomProfileColorHex
        )
        
        let params = user.eventParameters
        #expect(params["user_user_id"] as? String == randomUserId)
        #expect(params["user_email"] as? String == randomEmail)
        #expect(params["user_is_anonymous"] as? Bool == randomIsAnonymous)
        #expect(params["user_creation_date"] as? Date == randomCreationDate)
        #expect(params["user_creation_version"] as? String == randomCreationVersion)
        #expect(params["user_last_sign_in_date"] as? Date == randomLastSignInDate)
        #expect(params["user_did_complete_onboarding"] as? Bool == randomDidCompleteOnboarding)
        #expect(params["user_profile_color_hex"] as? String == randomProfileColorHex)
    }

    @Test("UserModel Profile Color with Valid Hex")
    func testProfileColorWithValidHex() async throws {
        let randomUserId = String.random
        let randomHexColor = String.randomHexColor()
        
        let user = UserModel(userId: randomUserId, profileColorHex: randomHexColor)
        let expectedColor = Color(hex: randomHexColor)
        
        #expect(user.profileColorCalculated == expectedColor)
    }

    @Test("UserModel Profile Color with Nil Hex")
    func testProfileColorWithNilHex() async throws {
        let randomUserId = String.random
        let user = UserModel(userId: randomUserId)
        
        #expect(user.profileColorCalculated == Color.accent)
    }

    @Test("UserModel Mock Data")
    func testMockData() async throws {
        let mocks = UserModel.mocks
        #expect(mocks.count == 4)
        
        #expect(mocks[0].userId != nil)
        #expect(mocks[0].profileColorHex != nil)
        
        #expect(mocks[1].userId != nil)
        #expect(mocks[1].profileColorHex != nil)
    }

    @Test("UserModel Codable Conformance")
    func testUserModelCodable() async throws {
        let randomUserId = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomIsAnonymous = Bool.random
        let randomCreationVersion = String.random
        let randomCreationDate = Date.random
        let randomLastSignInDate = Date.random
        let randomDidCompleteOnboarding = Bool.random
        let randomProfileColorHex = String.randomHexColor()
        
        let originalUser = UserModel(
            userId: randomUserId,
            email: randomEmail,
            isAnonymous: randomIsAnonymous,
            creationDate: randomCreationDate,
            creationVersion: randomCreationVersion,
            lastSignInDate: randomLastSignInDate,
            didCompleteOnboarding: randomDidCompleteOnboarding,
            profileColorHex: randomProfileColorHex
        )
        
        // Encode UserModel to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(originalUser)
        
        // Decode JSON back to UserModel
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedUser = try decoder.decode(UserModel.self, from: data)
        
        // Assert that all properties are equal
        #expect(decodedUser.userId == originalUser.userId)
        #expect(decodedUser.email == originalUser.email)
        #expect(decodedUser.isAnonymous == originalUser.isAnonymous)
        #expect(decodedUser.creationDate?.truncatedToSeconds() == originalUser.creationDate?.truncatedToSeconds())
        #expect(decodedUser.creationVersion == originalUser.creationVersion)
        #expect(decodedUser.lastSignInDate?.truncatedToSeconds() == originalUser.lastSignInDate?.truncatedToSeconds())
        #expect(decodedUser.didCompleteOnboarding == originalUser.didCompleteOnboarding)
        #expect(decodedUser.profileColorHex == originalUser.profileColorHex)
    }

    @Test("UserModel init from Auth")
    func testInitFromAuth() async throws {
        let randomUserId = String.random
        let randomEmail = "\(String.random)@example.com"
        let randomIsAnonymous = Bool.random
        let randomCreationVersion = String.random
        let randomCreationDate = Date.random
        let randomLastSignInDate = Date.random
        
        let auth = UserAuthInfo(
            uid: randomUserId,
            email: randomEmail,
            isAnonymous: randomIsAnonymous,
            creationDate: randomCreationDate,
            lastSignInDate: randomLastSignInDate
        )
        let user = UserModel(auth: auth, creationVersion: randomCreationVersion)
        
        #expect(user.userId == randomUserId)
        #expect(user.email == randomEmail)
        #expect(user.isAnonymous == randomIsAnonymous)
        #expect(user.creationDate == randomCreationDate)
        #expect(user.creationVersion == randomCreationVersion)
        #expect(user.lastSignInDate == randomLastSignInDate)
    }
}
