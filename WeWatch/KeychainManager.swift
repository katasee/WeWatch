import Foundation
import Security

internal final class KeychainManager {
    
    internal enum KeychainError: Error {
        
        case duplicateItem
        case unknown(OSStatus)
        case itemNotFound
        case unexpectedDataFormat
    }
    
    internal static func store(
        data: String,
        key: String
    ) throws {
        guard let data: Data = data.data(using: .utf8) else {
            throw KeychainError.itemNotFound
        }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            
            do {
                if let stringData = String(data: data, encoding: .utf8) {
                    _ = try update(key: key, newData: stringData)
                } else {
                    throw KeychainError.unexpectedDataFormat
                }
            } catch {
                throw KeychainError.duplicateItem
            }
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
    }
    
    internal static func getData(key: String) throws -> Data {
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
    
    internal static func remove(key: String) throws {
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
    
    internal static func update(key: String, newData: String) throws -> Bool {
        guard let data = newData.data(using: .utf8) else {
            throw KeychainError.unexpectedDataFormat
        }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        let updateQuery: [String: Any] = [
            kSecValueData as String: data
        ]
        let status = SecItemUpdate(query as CFDictionary, updateQuery as CFDictionary)
        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
        return status == errSecSuccess
    }
}

