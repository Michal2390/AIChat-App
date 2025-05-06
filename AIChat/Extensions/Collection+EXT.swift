//
//  Collection+EXT.swift
//  AIChat
//
//  Created by Michal Fereniec on 30/03/2025.
//

extension Collection {
    func first(upTo value: Int) -> [Element]? {
        guard !isEmpty else { return nil }

        let maxItems = Swift.min(count, value)
        return Array(prefix(maxItems))
    }

    func last(upTo value: Int) -> [Element]? {
        guard !isEmpty else { return nil }

        let maxItems = Swift.min(count, value)
        return Array(suffix(maxItems))
    }
}
