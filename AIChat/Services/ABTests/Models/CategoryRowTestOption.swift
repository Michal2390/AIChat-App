//
//  CategoryRowTestOption.swift
//  AIChat
//
//  Created by Michal Fereniec on 08/08/2025.
//
import SwiftUI

enum CategoryRowTestOption: String, Codable, CaseIterable {
    case original, top, hidden
    
    static var `default`: Self {
        .original
    }
}
