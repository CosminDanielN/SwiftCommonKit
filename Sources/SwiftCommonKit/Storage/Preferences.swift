//
//  Preferences.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import Foundation

/// Concrete implementation of `KeyValueStorage` using `UserDefaults`.
/// UserDefaults is thread-safe, so this class is Sendable and methods are synchronous.
public final class Preferences: KeyValueStorage, @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let suiteName: String?
    
    /// Initializes with a specific suite name.
    /// - Parameter suiteName: Optional suite name. If nil, `standard` is used.
    public init(suiteName: String? = nil) {
        self.suiteName = suiteName
        if let suiteName = suiteName, let defaults = UserDefaults(suiteName: suiteName) {
            self.userDefaults = defaults
        } else {
            self.userDefaults = .standard
        }
    }
    
    public func set<T>(_ value: T, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    public func get<T>(forKey key: String) -> T? {
        userDefaults.object(forKey: key) as? T
    }
    
    public func bool(forKey key: String) -> Bool {
        userDefaults.bool(forKey: key)
    }
    
    public func string(forKey key: String) -> String? {
        userDefaults.string(forKey: key)
    }
    
    public func integer(forKey key: String) -> Int {
        userDefaults.integer(forKey: key)
    }
    
    public func remove(forKey key: String) {
        // removeObject is a thread-safe operation on UserDefaults
        userDefaults.removeObject(forKey: key)
    }
    
    public func removeAll() {
        let nameToRemove = suiteName ?? Bundle.main.bundleIdentifier
        if let name = nameToRemove {
            userDefaults.removePersistentDomain(forName: name)
            userDefaults.synchronize()
        }
    }
}
