//
//  RevenueCatPaywallView.swift
//  AIChat
//
//  Created by Michal Fereniec on 12/01/2026.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct RevenueCatPaywallView: View {
    var body: some View {
        RevenueCatUI.PaywallView(displayCloseButton: true)
    }
}

#Preview {
    RevenueCatPaywallView()
}
