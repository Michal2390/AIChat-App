//
//  UserAuthInfo 2.swift
//  AIChat
//
//  Created by Michal Fereniec on 24/03/2025.
//
import FirebaseAuth

extension UserAuthInfo {
  
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
    }
}
