//
//  R_CacheService.swift
//  MetroRechka
//
//  Created by Слава Платонов on 21.07.2022.
//

import Foundation

protocol DefaultCacheService: AnyObject {
    var userDefaults: UserDefaults { get }
    var isUserCacheEmpty: Bool { get }
    func addUserToCache(_ user: R_User)
    func getUsersFromCache() -> [R_User]
    func deleteAll()
}

extension DefaultCacheService {
    var isUserCacheEmpty: Bool {
        guard let cachedUsers = userDefaults.object(forKey: "users") as? [String] else { return true }
        return cachedUsers.isEmpty
    }
}

final class R_CacheUserService: DefaultCacheService {
    let userDefaults: UserDefaults = UserDefaults.standard
    private let keychainHelper: _KeychainHelper = R_KeychainHelper()
    private let udKey = "users"
    
    func addUserToCache(_ user: R_User) {
        var _user = user
        _user.additionServices = nil
        _user.ticket = nil
        let data = _user.data
        let key = _user.key
        
        if var cachedUserData = userDefaults.object(forKey: udKey) as? [String] {
            if !existUserInCache(_user) {
                cachedUserData.append(key)
                userDefaults.setValue(cachedUserData, forKey: udKey)
                guard let _ = try? keychainHelper.save(value: data, forKey: key) else {
                    return
                }
            } else {
                return
            }
        } else {
            userDefaults.setValue([key], forKey: udKey)
            guard let _ = try? keychainHelper.save(value: data, forKey: key) else {
                return
            }
        }
    }
    
    func getUsersFromCache() -> [R_User] {
        var users: [R_User] = []
        if let cachedUsers = userDefaults.object(forKey: udKey) as? [String] {
            cachedUsers.forEach { key in
                if let user = try? keychainHelper.read(forKey: key) {
                    users.append(user)
                }
            }
        }
        return users
    }
    
    func deleteAll() {
        UserDefaults.standard.removeObject(forKey: udKey)
        do {
            let res = try keychainHelper.clearAll()
            print("DELETED ALL KEYCHAIN VALUES WITH RESULT - \(res)")
        } catch(let error) {
            print(error)
        }
    }
    
    private func existUserInCache(_ user: R_User) -> Bool {
        var result = false
        if let cachedKeys = userDefaults.object(forKey: udKey) as? [String] {
            var users: [R_User] = []
            cachedKeys.forEach { key in
                if let user = try? keychainHelper.read(forKey: key) {
                    users.append(user)
                }
            }
            if users.contains(user) {
                result = true
            }
        }
        return result
    }
}
