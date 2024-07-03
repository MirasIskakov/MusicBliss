//
//  AuthViewModel.swift
//  MusicBliss
//
//  Created by Miras Iskakov on 03.07.2024.
//

import Foundation

class AuthViewModel {
    func exchangeCodeForToken(code: String, completion: @escaping (Bool) -> Void) {
        AuthManager.shared.exchangeCodeForToken(code: code) { success in
            completion(success)
        }
    }
}
