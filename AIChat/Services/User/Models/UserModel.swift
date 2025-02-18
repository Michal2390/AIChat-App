//
//  UserModel.swift
//  AIChat
//
//  Created by Michal Fereniec on 18/02/2025.
//

import Foundation
import SwiftUI

struct UserModel {
    let userId: String
    let dateCreated: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    init(
        userId: String,
        dateCreated: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil
    ) {
        self.userId = userId
        self.dateCreated = dateCreated
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
    
    var profileColorCalculated: Color {
        guard let profileColorHex else { return .accent }
        return Color(hex: profileColorHex)
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            UserModel(
                userId: "user1",
                dateCreated: now,
                didCompleteOnboarding: true,
                profileColorHex: "#33A1FF"
            ),
            UserModel(
                userId: "user2",
                dateCreated: now.addingTimeInterval(days: -1),
                didCompleteOnboarding: false,
                profileColorHex: "#FF5733"
            ),
            UserModel(
                userId: "user3",
                dateCreated: now.addingTimeInterval(days: -3, hours: -2),
                didCompleteOnboarding: true,
                profileColorHex: "#7DFF33"
            ),
            UserModel(
                userId: "user4",
                dateCreated: now.addingTimeInterval(days: -5, hours: -4),
                didCompleteOnboarding: nil,
                profileColorHex: "#FF33A1"
            )]
    }
}
