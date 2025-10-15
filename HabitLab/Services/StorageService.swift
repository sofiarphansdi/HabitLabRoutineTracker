//
//  StorageService.swift
//  HabitLab
//
//  Created by Вадим Дзюба on 13.10.2025.
//

import Foundation

final class StorageService {
    static let shared = StorageService()
    
    private let tokenKey = "user_token"
    private let linkKey = "server_link"
    
    private init() {}
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
    
    var serverLink: String? {
        get {
            UserDefaults.standard.string(forKey: linkKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: linkKey)
        }
    }
    
    func hasToken() -> Bool {
        return token != nil
    }
    
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: linkKey)
    }
}

