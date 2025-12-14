//
//  PaywallView.swift
//  AIChat
//
//  Created by Michal Fereniec on 14/12/2025.
//

import SwiftUI

enum EntitlementOption: Codable, CaseIterable {
    case yearly
    
    var productId: String {
        switch self {
        case .yearly:
            return "michal.AIChat.yearly"
        }
    }
    
    static var allProductsIds: [String] {
        EntitlementOption.allCases.map({ $0.productId })
    }
}

struct PaywallView: View {
    
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        StoreKitPaywallView(
            onInAppPurchaseStart: onPurchaseStart,
            onInAppPurchaseCompletion: onPurchaseComplete
        )
            .screenAppearAnalytics(name: "Paywall")
    }
    
    private func onPurchaseStart(product: StoreKit.Product) {
        let product = AnyProduct(storeKitProduct: product)
        logManager.trackEvent(event: Event.purchaseStart(product: product))
    }
    
    private func onPurchaseComplete(product: StoreKit.Product, result: Result<Product.PurchaseResult, any Error>) {
        let product = AnyProduct(storeKitProduct: product)

        switch result {
        case .success(let value):
            switch value {
            case .success:
                logManager.trackEvent(event: Event.purchaseSuccess(product: product))
                dismiss()
            case .pending:
                logManager.trackEvent(event: Event.purchasePending(product: product))
            case .userCancelled:
                logManager.trackEvent(event: Event.purchaseCancelled(product: product))
            default:
                logManager.trackEvent(event: Event.purchaseUnknown(product: product))
            }
        case .failure(let error):
            logManager.trackEvent(event: Event.purchaseFail(error: error))
        }
    }
    
    enum Event: LoggableEvent {
        case purchaseStart(product: AnyProduct)
        case purchaseSuccess(product: AnyProduct)
        case purchasePending(product: AnyProduct)
        case purchaseCancelled(product: AnyProduct)
        case purchaseUnknown(product: AnyProduct)
        case purchaseFail(error: Error)
        
        var eventName: String {
            switch self {
            case .purchaseStart:                       return "PaywallView_Purchase_Start"
            case .purchaseSuccess:                     return "PaywallView_Purchase_Success"
            case .purchasePending:                     return "PaywallView_Purchase_Pending"
            case .purchaseCancelled:                   return "PaywallView_Purchase_Cancelled"
            case .purchaseUnknown:                     return "PaywallView_Purchase_Unknown"
            case .purchaseFail:                        return "PaywallView_Purchase_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .purchaseStart(product: let product), .purchaseSuccess(product: let product), .purchasePending(product: let product), .purchaseCancelled(product: let product), .purchaseUnknown(product: let product):
                return product.eventParameters
            case .purchaseFail(error: let error):
                return error.eventParameters
//            default:
//                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .purchaseFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
}

import StoreKit
struct StoreKitPaywallView: View {
    
    var onInAppPurchaseStart: ((Product) async -> Void)?
    var onInAppPurchaseCompletion: ((Product, Result<Product.PurchaseResult, any Error>) async -> Void)?
    
    var body: some View {
        SubscriptionStoreView(productIDs: EntitlementOption.allProductsIds) {
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
    PaywallView()
}
