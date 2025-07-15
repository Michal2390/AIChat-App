//
//  AuthService.swift
//  AIChat
//
//  Created by Michal Fereniec on 25/03/2025.
//
import SwiftUI
import Foundation

protocol AuthService: Sendable {
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?>
    func removeAuthenticatedUserListener(listener: any NSObjectProtocol)
    func getAuthenticatedUser() -> UserAuthInfo?
    func signInAnynomously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signOut() throws
    func deleteAccount() async throws
}
