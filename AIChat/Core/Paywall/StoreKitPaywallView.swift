//
//  StoreKitPaywallView.swift
//  AIChat
//
//  Created by Michal Fereniec on 14/12/2025.
//
import SwiftUI
import StoreKit
struct StoreKitPaywallView: View {
    
    var productIds: [String] = EntitlementOption.allProductsIds
    var onInAppPurchaseStart: ((Product) async -> Void)?
    var onInAppPurchaseCompletion: ((Product, Result<Product.PurchaseResult, any Error>) async -> Void)?
    
    var body: some View {
        SubscriptionStoreView(productIDs: productIds) {
            VStack(spacing: 8) {
                Text("AI Chat 😎")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Text("Get premium access to unlock all features.")
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .containerBackground(Color.accent.gradient, for: .subscriptionStore)
        }
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStoreControlStyle(.prominentPicker)
        .onInAppPurchaseStart(perform: onInAppPurchaseStart)
        .onInAppPurchaseCompletion(perform: onInAppPurchaseCompletion)
    }
}

#Preview {
    StoreKitPaywallView(onInAppPurchaseStart: nil, onInAppPurchaseCompletion: nil)
}
