//
//  errrr.swift
//  AIChat
//
//  Created by Michal Fereniec on 14/07/2025.
//

import Foundation

extension Error {
    
    var eventParameters: [String: Any] {
        [
            "error_description": localizedDescription
        ]
    }
}
