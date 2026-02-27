//
//  Keys.swift
//  AIChat
//
//  Created by Michal Fereniec on 01/08/2025.
//
import Foundation

struct Keys {
    static let mixpanel: String = {
        if let envValue = ProcessInfo.processInfo.environment["MIXPANEL_TOKEN"], !envValue.isEmpty {
            return envValue
        }
        if let plistValue = SecretsLoader.value(forKey: "MIXPANEL_TOKEN"), !plistValue.isEmpty {
            return plistValue
        }
        fatalError("Missing Mixpanel token. Provide MIXPANEL_TOKEN environment variable or create Secrets.plist.")
    }()
}

private enum SecretsLoader {
    static func value(forKey key: String) -> String? {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist") else {
            return nil
        }
        guard let data = NSDictionary(contentsOf: url) as? [String: Any] else {
            return nil
        }
        return data[key] as? String
    }
}
