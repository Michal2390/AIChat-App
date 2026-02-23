//
//  PaywallTestOption.swift
//  AIChat
//
//  Created by Michal Fereniec on 23/02/2026.
//
import SwiftUI

enum PaywallTestOption: String, Codable, CaseIterable {
    case storeKit, custom, revenueCat
    
    static var `default`: Self {
        .storeKit
    }
}
