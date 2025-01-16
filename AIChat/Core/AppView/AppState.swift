//
//  AppState.swift
//  AIChat
//
//  Created by Michal Fereniec on 16/01/2025.
//

import SwiftUI
 
@Observable
class AppState {
    private(set) var showTabbar: Bool { // private(set) enables to update this only within this AppState class
        didSet {
            UserDefaults.showTabbarView = showTabbar
        }
    }
    
    init(showTabbar: Bool = UserDefaults.showTabbarView) {
        self.showTabbar = showTabbar
    }
    
    func updateViewState(showTabBarView: Bool) {
        showTabbar = showTabBarView
    }
}

extension UserDefaults {
    
    private struct Keys {
        static let showTabbarView = "showTabbarView"
    }
    
    static var showTabbarView: Bool {
        get {
            standard.bool(forKey: Keys.showTabbarView)
        } set {
            standard.set(newValue, forKey: Keys.showTabbarView)
        }
    }
}
