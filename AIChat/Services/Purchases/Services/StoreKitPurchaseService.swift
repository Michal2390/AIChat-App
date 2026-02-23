//
//  StoreKitPurchaseService.swift
//  AIChat
//
//  Created by Michal Fereniec on 23/02/2026.
//
import StoreKit
struct StoreKitPurchaseService: PurchaseService {

    func listenForTransactions(onTransactionUpdated: ([PurchasedEntitlement]) async -> Void) async {
        for await update in StoreKit.Transaction.updates {
            if let transaction = try? update.payloadValue {
                await transaction.finish()
                
                if let entitlements = try? await getUserEntitlements() {
                    await onTransactionUpdated(entitlements)
                }
            }
        }
    }
    
    func getUserEntitlements() async throws -> [PurchasedEntitlement] {
        var activeTransactions: [PurchasedEntitlement] = []
        
        for await verificationResult in StoreKit.Transaction.currentEntitlements {
            
            switch verificationResult {
            case .verified(let transaction):
                let isActive: Bool
                if let expirationDate = transaction.expirationDate {
                    isActive = expirationDate >= .now
                } else {
                    isActive = transaction.revocationDate == nil
                }
                
                activeTransactions.append(
                        PurchasedEntitlement(
                           // id: String(transaction.id),
                            productId: transaction.productID,
                            expirationDate: transaction.expirationDate,
                            isActive: isActive,
                            originalPurchaseDate: transaction.originalPurchaseDate,
                            latestPurchaseDate: transaction.purchaseDate,
                            ownershipType: EntitlementOwnershipOption(type: transaction.ownershipType),
                            isSandbox: transaction.environment == .sandbox,
                            isVerified: true
                        )
                    )
            case .unverified:
                break
            }
        }
        
        return activeTransactions
    }
    
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        let products = try await Product.products(for: productIds)
        return products.compactMap({ AnyProduct(storeKitProduct: $0) })
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        try await AppStore.sync()
        return try await getUserEntitlements()
    }
    
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        let products = try await Product.products(for: [productId])
        
        guard let product = products.first else {
            throw PurchaseError.productNotFound
        }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verificationResult):
            let transaction = try verificationResult.payloadValue
            await transaction.finish()
            
            return try await getUserEntitlements()
        case .userCancelled:
            throw PurchaseError.userCancelledPurchase
        default:
            throw PurchaseError.failedToPurchase
        }
    }
    
    func logIn(userId: String) async throws -> [PurchasedEntitlement] {
        // StoreKit does not require user profile / log in
        try await getUserEntitlements()
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        // StoreKit does not require user profile / log in
    }
    
    func logOut() async throws {
        // StoreKit does not require user profile / log in
    }
}
