//
//  RevenueCatPurchaseService.swift
//  AIChat
//
//  Created by Michal Fereniec on 23/02/2026.
//
import RevenueCat

struct RevenueCatPurchaseService: PurchaseService {
    
    init(apiKey: String, logLevel: LogLevel = .warn) {
        Purchases.configure(withAPIKey: apiKey)
        Purchases.logLevel = logLevel
        Purchases.shared.attribution.collectDeviceIdentifiers()
    }
    
    func listenForTransactions(onTransactionUpdated: @Sendable ([PurchasedEntitlement]) async -> Void) async {
        for await customerInfo in Purchases.shared.customerInfoStream {
            let entitlements = customerInfo.entitlements.all.asPurchasedEntitlements()
            await onTransactionUpdated(entitlements)
        }
    }
    
    func getUserEntitlements() async throws -> [PurchasedEntitlement] {
        let customerInfo = try await Purchases.shared.customerInfo()
        let entitlements = customerInfo.entitlements.all.asPurchasedEntitlements()
        return entitlements
    }
    
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        let products = await Purchases.shared.products(productIds)
        return products.map( { AnyProduct(revenueCatProduct: $0) })
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        let customerInfo = try await Purchases.shared.restorePurchases()
        let entitlements = customerInfo.entitlements.all.asPurchasedEntitlements()
        return entitlements
    }
    
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        let products = await Purchases.shared.products([productId])
        
        guard let product = products.first else {
            throw PurchaseError.productNotFound
        }
        
        let result = try await Purchases.shared.purchase(product: product)
        let customerInfo = result.customerInfo
        let entitlements = customerInfo.entitlements.all.asPurchasedEntitlements()
        return entitlements
    }
    
    func logIn(userId: String) async throws -> [PurchasedEntitlement] {
        let (customerInfo, _) = try await Purchases.shared.logIn(userId)
        let entitlements = customerInfo.entitlements.all.asPurchasedEntitlements()
        return entitlements
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        if let email = attributes.email {
            Purchases.shared.attribution.setEmail(email)
        }
        
        if let firebaseAppInstanceId = attributes.firebaseAppInstanceId {
            Purchases.shared.attribution.setFirebaseAppInstanceID(firebaseAppInstanceId)
        }
        
        if let mixpanelDistinictId = attributes.mixpanelDistinictId {
            Purchases.shared.attribution.setMixpanelDistinctID(mixpanelDistinictId)
        }
    }
    
    func logOut() async throws {
        _ = try await Purchases.shared.logOut()
    }
}
