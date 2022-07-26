//
//  R_KeychainHelper.swift
//  MetroRechka
//
//  Created by Слава Платонов on 21.07.2022.
//

import Foundation

final public class R_KeychainHelper {
    
    private let key = "cacheUsers"
    
    var isCacheEmpty: Bool {
        guard let userData = try? getUsersFromKeychain() else { return true }
        return userData.isEmpty
    }

    enum KeychainErrors: Error {
        case itemNotFound
        case badData
        case duplicateItem
        case genericError(OSStatus)
    }
    
    func saveToKeychain(_ user: R_User) throws {
        var users: [R_User] = []
        var _user = user
        _user.additionServices = nil
        _user.ticket = nil
        if let cachedUsers = try? getUsersFromKeychain(), !cachedUsers.isEmpty {
            if cachedUsers.contains(_user) {
                return
            } else {
                users = cachedUsers
                users.append(_user)
                guard let _ = try? updateKeychain(users) else { return }
                return
            }
        } else {
            users.append(_user)
        }
        guard let data = encodeUsers(users) else {
            throw KeychainErrors.badData
        }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status != errSecDuplicateItem else {
            throw KeychainErrors.duplicateItem
        }
        guard status == 0 else {
            print(SecCopyErrorMessageString(status, nil) as Any)
            throw KeychainErrors.genericError(status)
        }
    }
    
    func getUsersFromKeychain() throws -> [R_User] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            throw KeychainErrors.itemNotFound
        }
        guard status == errSecSuccess else {
            throw KeychainErrors.genericError(status)
        }
        guard let existingItem = item as? [String: Any],
              let secureData = existingItem[kSecValueData as String] as? Data else {
            throw KeychainErrors.badData
        }
        let users = decodeUsers(from: secureData)
        return users
    }

    func clearAll() throws -> Bool {
        let query: [String: Any] = [kSecClass as String : kSecClassGenericPassword]
        let status = SecItemDelete(query as CFDictionary)
        guard status == 0 else {
            throw KeychainErrors.genericError(status)
        }
        return status == noErr
    }
    
    private func updateKeychain(_ users: [R_User]) throws {
        guard let data = encodeUsers(users) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecItemNotFound else {
            throw KeychainErrors.itemNotFound
        }
        guard status == 0 else {
            print(SecCopyErrorMessageString(status, nil) as Any)
            throw KeychainErrors.genericError(status)
        }
    }
    
    private func encodeUsers(_ users: [R_User]) -> Data? {
        guard let data = try? JSONEncoder().encode(users) else { return nil }
        return data
    }
    
    private func decodeUsers(from data: Data) -> [R_User] {
        guard let users = try? JSONDecoder().decode([R_User].self, from: data) else { return [] }
        return users
    }
}
