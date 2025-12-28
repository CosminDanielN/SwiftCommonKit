//
//  SecuredPreferences.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import Foundation
import Security

/// Errors that can occur during secure storage operations.
public enum SecuredStorageError: Error, Sendable {
    case duplicateEntry
    case unknown(OSStatus)
    case itemNotFound
    case invalidData
    case unhandledError(status: OSStatus)
}

/// Concrete implementation of `SecuredStorage` using Keychain Services.
/// Implemented as an actor to ensure thread safety and strict concurrency.
public actor SecuredPreferences: SecuredStorage {
    
    public init() {}
    
    public func save(data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // Item already exists, update it
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
            ]
            
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary)
            if updateStatus != errSecSuccess {
                throw SecuredStorageError.unhandledError(status: updateStatus)
            }
        } else if status != errSecSuccess {
            throw SecuredStorageError.unhandledError(status: status)
        }
    }
    
    public func read(forKey key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            return dataTypeRef as? Data
        } else if status == errSecItemNotFound {
            return nil
        } else {
            throw SecuredStorageError.unhandledError(status: status)
        }
    }
    
    public func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw SecuredStorageError.unhandledError(status: status)
        }
    }
}
