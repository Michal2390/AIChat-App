//
//  PurchaseManager.swift
//  AIChat
//
//  Created by Michal Fereniec on 11/09/2025.
//

import SwiftUI

protocol PurchaseService {
    
}

struct MockPurchaseService: PurchaseService {
    
}

import StoreKit
struct StoreKitPurchaseService: PurchaseService {

    func listenForTransactions(onTransactionUpdated: ([PurchasedEntitlement]) -> Void) async {
        for await update in StoreKit.Transaction.updates {
            if let transaction = try? update.payloadValue {
                let entitlements = await getUserEntitlements()
                onTransactionUpdated(entitlements)
                await transaction.finish()
            }
        }
    }
    
    func getUserEntitlements() async -> [PurchasedEntitlement] {
        var activeTransactions: [StoreKit.Transaction] = []
        
        for await verificationResult in StoreKit.Transaction.currentEntitlements {
            
            switch verificationResult {
            case .verified(let transaction):
                let isActive: Bool
                if let expirationDate = transaction.expirationDate {
                    isActive = expirationDate >= .now
                } else {
                    isActive = transaction.revocationDate == nil
                }
                
                activeTransactions
                    .append(
                        PurchasedEntitlement(
                            id: transaction.id,
                            productId: transaction.productID,
                            expirationDate: transaction.expirationDate,
                            isActive: isActive,
                            originalPurchaseDate: transaction.originalPurchaseDate,
                            latestPurchaseDate: transaction.latestPurchaseDate,
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
}



@MainActor
@Observable
class PurchaseManager {
    
    private let service: PurchaseService
    
    init(service: PurchaseService) {
        self.service = service
    }
    
}
