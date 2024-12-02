//
//  KeychainManager.swift
//  WeWatch
//
//  Created by Anton on 30/11/2024.
//


//
//  KeychainManager.swift
//  test KeyChain
//
//  Created by Anton on 25/11/2024.
//

import Foundation
import Security

class KeychainManager {
    
    enum KeychainError: Error {
        case duplicateItem
        case unknown(OSStatus)
        case itemNotFound
        case unexpectedDataFormat
    }
    
    static func store(data: String, key: String) throws {
        let data = data.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            throw KeychainError.duplicateItem
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
    }
    
    static func getData(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
        
        guard let data = item as? Data else {
            throw KeychainError.unexpectedDataFormat
        }
        return data
    }
    
    static func remove(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status) 
        }
    }
}
