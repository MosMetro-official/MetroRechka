//
//  R_KeychainHelper.swift
//  MetroRechka
//
//  Created by Слава Платонов on 21.07.2022.
//

import Foundation

protocol _KeychainHelper: AnyObject {
    func save(value: Data, forKey: String) throws -> Bool
    func read(forKey: String) throws -> R_User
    func clearAll() throws -> Bool
}

final public class R_KeychainHelper: _KeychainHelper {

    enum KeychainErrors: Error {
        case itemNotFound
        case badSuccess
        case badData
        case genericError(OSStatus)
    }
    
    func save(value: Data, forKey: String) throws -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: forKey,
            kSecValueData as String: value
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == 0 else {
            throw KeychainErrors.genericError(status)
        }
        return status == noErr
    }
    
    func read(forKey: String) throws -> R_User {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: forKey,
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
            throw KeychainErrors.badData
        }
        guard let existingItem = item as? [String: Any],
              let secureData = existingItem[kSecValueData as String] as? Data,
              let user = R_User(data: secureData) else {
            throw KeychainErrors.badData
        }
        return user
    }

    func clearAll() throws -> Bool {
        let query: [String: Any] = [kSecClass as String : kSecClassGenericPassword]
        let status = SecItemDelete(query as CFDictionary)
        guard status == 0 else {
            throw KeychainErrors.genericError(status)
        }
        return status == noErr
    }
}
