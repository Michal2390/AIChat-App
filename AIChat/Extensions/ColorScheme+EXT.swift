//
//  ColorScheme+EXT.swift
//  AIChat
//
//  Created by Michal Fereniec on 01/08/2025.
//
import SwiftUI

extension ColorScheme {
    
    var backgroundPrimary: Color {
            self == .dark ? Color(uiColor: .secondarySystemBackground) : Color(uiColor: .systemBackground)
    }
    
    var backgroundSecondary: Color {
            self == .dark ? Color(uiColor: .systemBackground) : Color(uiColor: .secondarySystemBackground)
    }
}
