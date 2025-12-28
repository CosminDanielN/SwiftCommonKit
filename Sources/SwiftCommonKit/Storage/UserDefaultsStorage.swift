//
//  UserDefaultsStorage.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import Foundation

/// Protocol for type-safe UserDefaults storage.
///
/// Provides a clean interface for storing and retrieving values from UserDefaults
/// with support for custom containers (suites).
@MainActor
public protocol UserDefaultsStorage {
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
