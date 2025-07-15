//
//  UserManager.swift
//  AIChat
//
//  Created by Michal Fereniec on 26/03/2025.
//
import SwiftUI

@MainActor
@Observable
class UserManager {

    private let local: LocalUserPersistence
    private let remote: RemoteUserService
    private let logManager: LogManager?
    
    private(set) var currentUser: UserModel?
    private var currentUserListener: ListenerRegistration?

    init(services: UserServices, logManager: LogManager? = nil) {
        self.remote = services.remote
        self.local = services.local
        self.logManager = logManager
        self.currentUser = local.getCurrentUser()
    }
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        logManager?.trackEvent(event: Event.logInStart(user: user))
        
        try await remote.saveUser(user: user)
        logManager?.trackEvent(event: Event.logInSuccess(user: user))
        
        addCurrentUserListener(userId: auth.uid)
    }

    private func addCurrentUserListener(userId: String) {
        currentUserListener?.remove()
        logManager?.trackEvent(event: Event.remoteListenerStart)

        Task {
            do {
                for try await value in remote.streamUser(userId: userId, onListenerConfigured: { listener in
                    self.currentUserListener = listener
                }) {
                    self.currentUser = value
                    logManager?.trackEvent(event: Event.remoteListenerSuccess(user: value))
                    logManager?.addUserProperties(dict: value.eventParameters, isHighPriority: true)
                    
                    self.saveCurrentUserLocally()
                }
            } catch {
                logManager?.trackEvent(event: Event.remoteListenerFail(error: error))
            }
        }
    }

    private func saveCurrentUserLocally() {
        logManager?.trackEvent(event: Event.saveLocalStart(user: currentUser))
        
        Task {
            do {
                try local.saveCurrentUser(user: currentUser)
                logManager?.trackEvent(event: Event.saveLocalSuccess(user: currentUser))
            } catch {
                logManager?.trackEvent(event: Event.saveLocalFail(error: error))
            }
        }
    }

    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserId()
        try await remote.markOnboardingCompleted(userId: uid, profileColorHex: profileColorHex)
    }

    func signOut() {
        currentUserListener?.remove()
        currentUserListener = nil
        currentUser = nil
        logManager?.trackEvent(event: Event.signOut)
    }

    func deleteCurrentUser() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        
        let uid = try currentUserId()
        try await remote.deleteUser(userId: currentUser?.userId ?? "")
        logManager?.trackEvent(event: Event.deleteAccountSuccess)
        
        signOut()
}

    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return uid
    }

    enum UserManagerError: LocalizedError {
        case noUserId
    }
    
    enum Event: LoggableEvent {
        case logInStart(user: UserModel?)
        case logInSuccess(user: UserModel?)
        case remoteListenerStart
        case remoteListenerSuccess(user: UserModel?)
        case remoteListenerFail(error: Error)
        case saveLocalStart(user: UserModel?)
        case saveLocalSuccess(user: UserModel?)
        case saveLocalFail(error: Error)
        case signOut
        case deleteAccountStart
        case deleteAccountSuccess
        
        var eventName: String {
            switch self {
            case .logInStart:               return "UserManager_LogIn_Start"
            case .logInSuccess:             return "UserManager_LogIn_Success"
            case .remoteListenerStart:      return "UserManager_RemoteListener_Start"
            case .remoteListenerSuccess:    return "UserManager_RemoteListener_Success"
            case .remoteListenerFail:       return "UserManager_RemoteListener_Fail"
            case .saveLocalStart:           return "UserManager_LocalListener_Start"
            case .saveLocalSuccess:         return "UserManager_LocalListener_Success"
            case .saveLocalFail:            return "UserManager_LocalListener_Fail"
            case .signOut:                  return "UserManager_SignOut"
            case .deleteAccountStart:       return "UserManager_DeleteAccount_Start"
            case .deleteAccountSuccess:     return "UserManager_DeleteAccount_Success"
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case .logInStart(user: let user), .logInSuccess(user: let user), .remoteListenerSuccess(user: let user), .saveLocalStart(user: let user), .saveLocalSuccess(user: let user):
                return user?.eventParameters
            case .saveLocalFail(error: let error), .remoteListenerFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .saveLocalFail, .remoteListenerFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
