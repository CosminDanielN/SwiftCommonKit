//
//  StorageProtocols.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import Foundation

/// Protocol for type-safe Key-Value storage (e.g. UserDefaults).
/// Non-isolated to allow background access (UserDefaults is thread-safe).
public protocol KeyValueStorage: Sendable {
    /// Saves a value for a given key.
    func set<T>(_ value: T, forKey key: String)
    
    /// Retrieves a value for a given key.
    func get<T>(forKey key: String) -> T?
    
    /// Retrieves a boolean value for a given key.
    func bool(forKey key: String) -> Bool
    
    /// Retrieves a string value for a given key.
    func string(forKey key: String) -> String?
    
    /// Retrieves an integer value for a given key.
    func integer(forKey key: String) -> Int
    
    /// Removes a value for a given key.
    func remove(forKey key: String)
    
    /// Removes all values from the storage.
    func removeAll()
}

/// Protocol for secure storage (e.g., Keychain).
/// Async methods to support actor-based implementations (avoiding Main Thread blocks).
public protocol SecuredStorage: Sendable {
    /// Saves data securely for a given key.
    func save(data: Data, forKey key: String) async throws
    
    /// Retrieves secure data for a given key.
    func read(forKey key: String) async throws -> Data?
    
    /// Deletes secure data for a given key.
    func delete(forKey key: String) async throws
}

/// Protocol for file-based storage.
/// Async methods for safe Disk I/O off the Main Thread.
public protocol FileStorage: Sendable {
    /// Saves a Codable item to disk.
    func save<T: Encodable & Sendable>(_ item: T, name: String) async throws
    
    /// Retrieves a Codable item from disk.
    func retrieve<T: Decodable & Sendable>(name: String) async throws -> T
    
    /// Removes an item from disk.
    func remove(name: String) async throws
}
