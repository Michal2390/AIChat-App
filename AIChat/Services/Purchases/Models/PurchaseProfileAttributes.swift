//
//  PurchaseProfileAttributes.swift
//  AIChat
//
//  Created by Michal Fereniec on 23/02/2026.
//
struct PurchaseProfileAttributes {
    let email: String?
    let firebaseAppInstanceId: String?
    let mixpanelDistinictId: String?
    
    init(
        email: String? = nil,
        firebaseAppInstanceId: String? = nil,
        mixpanelDistinctId: String? = nil
    ) {
        self.email = email
        self.firebaseAppInstanceId = firebaseAppInstanceId
        self.mixpanelDistinictId = mixpanelDistinctId
    }
}
