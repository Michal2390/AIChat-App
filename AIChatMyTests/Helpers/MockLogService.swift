//
//  MockLogManager.swift
//  AIChatMyTests
//
//  Created by Michal Fereniec on 23/02/2026.
//

import SwiftUI
@testable import AIChat

class MockLogService: LogService {
    
    var identifiedUsers: [(userId: String, name: String?, email: String?)] = []
    var trackedEvents: [AnyLoggableEvent] = []
    var addedUserProperties: [[String: Any]] = []
    
    func identifyUser(userId: String, name: String?, email: String?) {
        identifiedUsers.append((userId, name, email))
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        addedUserProperties.append(dict)
    }
    
    func deleteUserProfile() {
        // Implement if needed for specific tests
    }
    
    func trackEvent(event: LoggableEvent) {
        let anyEvent = AnyLoggableEvent(eventName: event.eventName, parameters: event.parameters, type: event.type)
        trackedEvents.append(anyEvent)
    }
    
    func trackScreenEvent(event: LoggableEvent) {
        let anyEvent = AnyLoggableEvent(eventName: event.eventName, parameters: event.parameters, type: event.type)
        trackedEvents.append(anyEvent)
    }
}
