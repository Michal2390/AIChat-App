//
//  UserDefaultPropertyWrapper.swift
//  AIChat
//
//  Created by Michal Fereniec on 07/08/2025.
//
import SwiftUI

protocol UserDefaultsCompatible { }
extension Bool: UserDefaultsCompatible { }
extension Int: UserDefaultsCompatible { }
extension Float: UserDefaultsCompatible { }
extension Double: UserDefaultsCompatible { }
extension String: UserDefaultsCompatible { }
extension URL: UserDefaultsCompatible { }

@propertyWrapper
struct UserDefault<T: UserDefaultsCompatible> {
    let key: String
    let startingValue: T
    
    init(key: String, startingValue: T) {
        self.key = key
        self.startingValue = startingValue
    }
    
    var wrappedValue: T {
        get {
            if let savedValue = UserDefaults.standard.value(forKey: key) as? T {
                return savedValue
            } else {
                UserDefaults.standard.set(startingValue, forKey: key)
                return startingValue
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
