//
//  MockPurchaseService.swift
//  AIChat
//
//  Created by Michal Fereniec on 23/02/2026.
//

struct MockPurchaseService: PurchaseService {
    
    let activeEntitlements: [PurchasedEntitlement]
    
    init(activeEntitlements: [PurchasedEntitlement] = []) {
        self.activeEntitlements = activeEntitlements
    }
    
    func listenForTransactions(onTransactionUpdated: ([PurchasedEntitlement]) async -> Void) async {
        await onTransactionUpdated(activeEntitlements)
    }
    
    func getUserEntitlements() async -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        return AnyProduct.mocks.filter { product in
            return productIds.contains(product.id)
        }
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func logIn(userId: String) async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        
    }
    
    func logOut() async throws {
        
    }
}
