//
//  PurchaseError.swift
//  AIChat
//
//  Created by Michal Fereniec on 23/02/2026.
//
import Foundation

enum PurchaseError: LocalizedError {
    case productNotFound, userCancelledPurchase, failedToPurchase
}
