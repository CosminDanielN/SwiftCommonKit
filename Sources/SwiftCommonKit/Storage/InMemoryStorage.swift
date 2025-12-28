//
//  InMemoryStorage.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import Foundation

/// In-memory implementation of storage for testing and preview purposes.
@MainActor
public final class InMemoryStorage: UserDefaultsStorage {
    public var storage: [String: Any] = [:]
    
    public init() {}
    
    public func set<T>(_ value: T, forKey key: String) {
        storage[key] = value
    }
    
    public func get<T>(forKey key: String) -> T? {
        storage[key] as? T
    }
    
    public func bool(forKey key: String) -> Bool {
        storage[key] as? Bool ?? false
    }
    
    public func string(forKey key: String) -> String? {
        storage[key] as? String
    }
    
    public func integer(forKey key: String) -> Int {
        storage[key] as? Int ?? 0
    }
    
    public func remove(forKey key: String) {
        storage.removeValue(forKey: key)
    }
    
    public func removeAll() {
        storage.removeAll()
    }
}
