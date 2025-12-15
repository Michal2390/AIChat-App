//
//  PaywallView.swift
//  AIChat
//
//  Created by Michal Fereniec on 14/12/2025.
//

import SwiftUI
import StoreKit

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
    
    @Environment(PurchaseManager.self) private var purchaseManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss

    @State private var products: [AnyProduct] = []
    @State private var productIds: [String] = EntitlementOption.allProductsIds
    @State private var showAlert: AnyAppAlert?

    var body: some View {
        ZStack {
            if products.isEmpty {
                ProgressView()
            } else {
                CustomPaywallView(
                    products: products,
                    onBackButtonPressed: onBackButtonPressed,
                    onRestorePurchasePressed: onRestorePurchasePressed,
                    onPurchaseProductPressed: onPurchaseProductPressed
                )
            }
        }
            //        StoreKitPaywallView(
            //            productIds: productIds,
            //            onInAppPurchaseStart: onPurchaseStart,
            //            onInAppPurchaseCompletion: onPurchaseComplete
            //        )
            .screenAppearAnalytics(name: "Paywall")
            .showCustomAlert(alert: $showAlert)
            .task {
                await onLoadProducts()
            }
    }
    
    private func onLoadProducts() async {
        do {
            products = try await purchaseManager.getProducts(productIds: productIds)
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
    
    private func onBackButtonPressed() {
        logManager.trackEvent(event: Event.backButtonPressed)
        dismiss()
    }
    
    private func onRestorePurchasePressed() {
        logManager.trackEvent(event: Event.restorePurchaseStart)
        
        Task {
            do {
                let entitlements = try await purchaseManager.restorePurchase()
                
                if entitlements.hasActiveEntitlement {
                    dismiss()
                }
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func onPurchaseProductPressed(product: AnyProduct) {
        logManager.trackEvent(event: Event.purchaseStart(product: product))
        
        Task {
            do {
                let entitlements = try await purchaseManager.purchaseProduct(productId: product.id)
                logManager.trackEvent(event: Event.purchaseSuccess(product: product))
                
                if entitlements.hasActiveEntitlement {
                    dismiss()
                }
            } catch {
                logManager.trackEvent(event: Event.purchaseFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
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
        case loadProductsStart
        case restorePurchaseStart
        case backButtonPressed
        
        var eventName: String {
            switch self {
            case .purchaseStart:                       return "PaywallView_Purchase_Start"
            case .purchaseSuccess:                     return "PaywallView_Purchase_Success"
            case .purchasePending:                     return "PaywallView_Purchase_Pending"
            case .purchaseCancelled:                   return "PaywallView_Purchase_Cancelled"
            case .purchaseUnknown:                     return "PaywallView_Purchase_Unknown"
            case .purchaseFail:                        return "PaywallView_Purchase_Fail"
            case .loadProductsStart:                   return "PaywallView_Load_Start"
            case .restorePurchaseStart:                return "PaywallView_Restore_Start"
            case .backButtonPressed:                   return "PaywallView_BackButton_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .purchaseStart(product: let product), .purchaseSuccess(product: let product), .purchasePending(product: let product), .purchaseCancelled(product: let product), .purchaseUnknown(product: let product):
                return product.eventParameters
            case .purchaseFail(error: let error):
                return error.eventParameters
            default:
                return nil
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

#Preview {
    PaywallView()
}
