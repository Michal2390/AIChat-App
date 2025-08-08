//
//  ABTestManager.swift
//  AIChat
//
//  Created by Michal Fereniec on 06/08/2025.
//
import SwiftUI

@MainActor
@Observable
class ABTestManager {
    
    private let service: ABTestService
    private let logManager: LogManager?
    var activeTests: ActiveABTests
    
    init(service: ABTestService, logManager: LogManager? = nil) {
        self.logManager = logManager
        self.service = service
        self.activeTests = service.activeTests
        self.configure()
    }
    
    private func configure() {
        Task {
            do {
                activeTests = try await service.fetchUpdatedConfig()
                logManager?.trackEvent(event: Event.fetchRemoteConfigSuccess)
                logManager?.addUserProperties(dict: activeTests.eventParameters, isHighPriority: false)
            } catch {
                logManager?.trackEvent(event: Event.fetchRemoteConfigFail(error: error))
            }
        }
        logManager?.addUserProperties(dict: activeTests.eventParameters, isHighPriority: false)
    }
    
    func override(updatedTests: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTests: updatedTests)
        configure()
    }
    
    enum Event: LoggableEvent {
        case fetchRemoteConfigSuccess
        case fetchRemoteConfigFail(error: Error)
        
        var eventName: String {
            switch self {
            case .fetchRemoteConfigSuccess:        return "ABMan_FetchRemote_Success"
            case .fetchRemoteConfigFail:           return "ABMan_FetchRemote_Fail"
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case .fetchRemoteConfigFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .fetchRemoteConfigFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
}
