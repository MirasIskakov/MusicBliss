//
//  AuthManager.swift
//  MusicBliss
//
//  Created by Miras Iskakov on 27.06.2024.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    struct Constants {
        static let clientID = "clientID"
        static let clientSecret = "clientSecret"
    }
    
    private init() {}
    
    var isSingedIn: Bool {
        return false
    }
    
    private var accessToken: String? {
        return nil
    }
    
    private var refreshToken: String? {
        return nil
    }
    
    private var tokenExpirationDate: Date? {
        return nil
    }
    
    private var shouldRefreshToken: Bool {
        return false
    }
}
