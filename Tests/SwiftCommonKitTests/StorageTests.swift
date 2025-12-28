//
//  StorageTests.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import XCTest
@testable import SwiftCommonKit

final class StorageTests: XCTestCase {
    
    // MARK: - Preferences Tests
    
    func testPreferences_setAndGet() {
        let storage = Preferences(suiteName: "test.preferences")
        storage.removeAll()
        
        let key = "testKey"
        let value = "testValue"
        
        storage.set(value, forKey: key)
        let retrieved: String? = storage.get(forKey: key)
        
        XCTAssertEqual(retrieved, value)
        
        storage.removeAll()
    }

    func testPreferences_types() {
        let storage = Preferences(suiteName: "test.types")
        storage.removeAll()
        
        // Bool
        storage.set(true, forKey: "boolKey")
        XCTAssertTrue(storage.bool(forKey: "boolKey"))
        
        // Int
        storage.set(42, forKey: "intKey")
        XCTAssertEqual(storage.integer(forKey: "intKey"), 42)
        
        // String
        storage.set("Hello", forKey: "stringKey")
        XCTAssertEqual(storage.string(forKey: "stringKey"), "Hello")
        
        storage.removeAll()
    }
    
    func testPreferences_isolation() {
        let suite1 = Preferences(suiteName: "test.suite1")
        let suite2 = Preferences(suiteName: "test.suite2")
        
        suite1.removeAll()
        suite2.removeAll()
        
        suite1.set("Value1", forKey: "key")
        suite2.set("Value2", forKey: "key")
        
        XCTAssertEqual(suite1.string(forKey: "key"), "Value1")
        XCTAssertEqual(suite2.string(forKey: "key"), "Value2")
        
        suite1.removeAll()
        XCTAssertNil(suite1.string(forKey: "key"))
        XCTAssertEqual(suite2.string(forKey: "key"), "Value2")
        
        suite2.removeAll()
    }
    
    // MARK: - DiskStorage Tests
    
    func testDiskStorage_saveAndRetrieve() async throws {
        let storage = DiskStorage(directory: .cachesDirectory)
        let fileName = "testFile"
        let testData = TestData(id: 1, name: "Test")
        
        try await storage.save(testData, name: fileName)
        let retrieved: TestData = try await storage.retrieve(name: fileName)
        
        XCTAssertEqual(retrieved, testData)
        
        try await storage.remove(name: fileName)
    }
    
    func testDiskStorage_overwrite() async throws {
        let storage = DiskStorage(directory: .cachesDirectory)
        let fileName = "testOverwrite"
        let initialData = TestData(id: 1, name: "Initial")
        let newData = TestData(id: 2, name: "Updated")
        
        try await storage.save(initialData, name: fileName)
        let retrievedInitial: TestData = try await storage.retrieve(name: fileName)
        XCTAssertEqual(retrievedInitial, initialData)
        
        try await storage.save(newData, name: fileName)
        let retrievedUpdated: TestData = try await storage.retrieve(name: fileName)
        XCTAssertEqual(retrievedUpdated, newData)
        
        try await storage.remove(name: fileName)
    }
    
    func testDiskStorage_remove() async throws {
        let storage = DiskStorage(directory: .cachesDirectory)
        let fileName = "testFileRemove"
        let testData = TestData(id: 2, name: "TestRemove")
        
        try await storage.save(testData, name: fileName)
        try await storage.remove(name: fileName)
        
        do {
            let _: TestData = try await storage.retrieve(name: fileName)
            XCTFail("Should throw error")
        } catch let error as DiskStorageError {
            if case .fileNotFound = error {
                // Success
            } else {
                XCTFail("Wrong error case: \(error)")
            }
        } catch {
             XCTFail("Wrong error type: \(error)")
        }
    }
    
    // MARK: - SecuredPreferences Tests
    
    func testSecuredPreferences_saveAndRead() async throws {
        let storage = SecuredPreferences()
        let key = "testSecureKey"
        let data = "secureData".data(using: .utf8)!
        
        // Cleanup first
        try? await storage.delete(forKey: key)
        
        try await storage.save(data: data, forKey: key)
        let retrieved = try await storage.read(forKey: key)
        
        XCTAssertEqual(retrieved, data)
        
        try await storage.delete(forKey: key)
    }
    
    func testSecuredPreferences_overwrite() async throws {
        let storage = SecuredPreferences()
        let key = "testSecureOverwrite"
        let initialData = "initial".data(using: .utf8)!
        let newData = "updated".data(using: .utf8)!
        
        // Cleanup
        try? await storage.delete(forKey: key)
        
        try await storage.save(data: initialData, forKey: key)
        let retrieved1 = try await storage.read(forKey: key)
        XCTAssertEqual(retrieved1, initialData)
        
        try await storage.save(data: newData, forKey: key)
        let retrieved2 = try await storage.read(forKey: key)
        XCTAssertEqual(retrieved2, newData)
        
        try await storage.delete(forKey: key)
    }
    
    func testSecuredPreferences_notFound() async throws {
        let storage = SecuredPreferences()
        let key = "nonExistentKey"
        
        // Ensure it doesn't exist
        try? await storage.delete(forKey: key)
        
        let retrieved = try await storage.read(forKey: key)
        XCTAssertNil(retrieved)
    }
}

// MARK: - Helpers

struct TestData: Codable, Equatable, Sendable {
    let id: Int
    let name: String
}
