//
//  SomeCache.swift
//  
//
//  Created by Слава Платонов on 13.03.2022.
//

import Foundation

class SomeCache {
    static public let shared = SomeCache()
    
    private init() {}
    
    internal var cache: [String: [R_User]] = ["user": []]
    
    internal func replaceUser(on user: R_User) {
        guard var users = cache["user"] else { return }
        for (index, _) in users.enumerated() {
            users[index] = user
        }
    }
   
    internal func checkCache(for user: R_User) -> Bool {
        guard let users = cache["user"] else { return false }
        if users.contains(user) {
            return false
        }
        return true
    }
    
    internal func addToCache(user: R_User) {
        cache["user"]?.append(user)
    }
}
