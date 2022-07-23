//
//  R_CacheService.swift
//  MetroRechka
//
//  Created by Слава Платонов on 21.07.2022.
//

import Foundation

protocol DefaultCacheService: AnyObject {
    var isUserCacheEmpty: Bool { get }
    func addUserToCache(_ user: R_User)
    func getUsersFromCache() -> [R_User]
    func deleteAll()
}

extension DefaultCacheService {
    var isUserCacheEmpty: Bool {
        return getUsersFromCache().isEmpty
    }
}

final class R_CacheUserService: DefaultCacheService {
    private let userDefaults: UserDefaults = UserDefaults.standard
    private let keychainHelper: _KeychainHelper = R_KeychainHelper()
    
    func addUserToCache(_ user: R_User) {
        var _user = user
        _user.id = ""
        _user.document?.cardIdentityNumber = ""
        _user.additionServices = nil
        _user.ticket = nil
        let data = _user.data
        let keyForKeychain = _user.key
        
        if var cachedUsersData = UserDefaults.standard.object(forKey: "users") as? [Data] {
            if !existUserInCache(_user) {
                cachedUsersData.append(data)
                UserDefaults.standard.set(cachedUsersData, forKey: "users")
                if let id = user.document?.cardIdentityNumber {
                    guard let _ = try? keychainHelper.save(value: id, forKey: keyForKeychain) else {
                        return
                    }
                }
            } else {
                return
            }
        } else {
            UserDefaults.standard.set([data], forKey: "users")
            if let id = user.document?.cardIdentityNumber {
                guard let _ = try? keychainHelper.save(value: id, forKey: keyForKeychain) else {
                    return
                }
            }
        }
    }
    
    func getUsersFromCache() -> [R_User] {
        var users: [R_User] = []
        if let cachedUsers = UserDefaults.standard.object(forKey: "users") as? [Data] {
            cachedUsers.forEach { cachedUser in
                if var user = R_User(data: cachedUser) {
                    guard let passport = try? keychainHelper.read(forKey: user.key) else {
                        return
                    }
                    user.document?.cardIdentityNumber = passport
                    users.append(user)
                }
            }
        }
        return users
    }
    
    func deleteAll() {
        UserDefaults.standard.removeObject(forKey: "users")
        do {
            let res = try keychainHelper.clearAll()
            print("DELETED ALL KEYCHAIN VALUES WITH RESULT - \(res)")
        } catch(let error) {
            print(error)
        }
    }
        
    private func existUserInCache(_ user: R_User) -> Bool {
        var result: Bool = false
        if let cachedUsersData = UserDefaults.standard.object(forKey: "users") as? [Data] {
            let cachedUsers = cachedUsersData.map { R_User(data: $0) }
            let cachedUsersWithouId: [R_User?] = cachedUsers.map { user -> R_User? in
                var _user = user
                _user?.id = ""
                return _user
            }
            if cachedUsersWithouId.contains(user) {
                result = true
            }
        }
        return result
    }
}
