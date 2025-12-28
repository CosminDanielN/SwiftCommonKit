//
//  StorageTests.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import Testing
import Foundation
import SwiftData
@testable import SwiftCommonKit

@Suite("Storage Tests")
struct StorageTests {
    
    // MARK: - Preferences Tests
    
    @Test("Preferences: Set and Get value")
    func testPreferences_setAndGet() {
        let storage = Preferences(suiteName: "test.preferences")
        storage.removeAll()
        
        let key = "testKey"
        let value = "testValue"
        
        storage.set(value, forKey: key)
        let retrieved: String? = storage.get(forKey: key)
        
        #expect(retrieved == value)
        
        storage.removeAll()
    }

    @Test("Preferences: Handle different types")
    func testPreferences_types() {
        let storage = Preferences(suiteName: "test.types")
        storage.removeAll()
        
        // Bool
        storage.set(true, forKey: "boolKey")
        #expect(storage.bool(forKey: "boolKey") == true)
        
        // Int
        storage.set(42, forKey: "intKey")
        #expect(storage.integer(forKey: "intKey") == 42)
        
        // String
        storage.set("Hello", forKey: "stringKey")
        #expect(storage.string(forKey: "stringKey") == "Hello")
        
        storage.removeAll()
    }
    
    @Test("Preferences: Suite isolation")
    func testPreferences_isolation() {
        let suite1 = Preferences(suiteName: "test.suite1")
        let suite2 = Preferences(suiteName: "test.suite2")
        
        suite1.removeAll()
        suite2.removeAll()
        
        suite1.set("Value1", forKey: "key")
        suite2.set("Value2", forKey: "key")
        
        #expect(suite1.string(forKey: "key") == "Value1")
        #expect(suite2.string(forKey: "key") == "Value2")
        
        suite1.removeAll()
        #expect(suite1.string(forKey: "key") == nil)
        #expect(suite2.string(forKey: "key") == "Value2")
        
        suite2.removeAll()
    }
    
    // MARK: - DiskStorage Tests
    
    @Test("DiskStorage: Save and Retrieve")
    func testDiskStorage_saveAndRetrieve() async throws {
        let storage = DiskStorage(directory: .cachesDirectory)
        let fileName = "testFile"
        let testData = TestData(id: 1, name: "Test")
        
        try await storage.save(testData, name: fileName)
        let retrieved: TestData = try await storage.retrieve(name: fileName)
        
        #expect(retrieved == testData)
        
        try await storage.remove(name: fileName)
    }
    
    @Test("DiskStorage: Overwrite existing file")
    func testDiskStorage_overwrite() async throws {
        let storage = DiskStorage(directory: .cachesDirectory)
        let fileName = "testOverwrite"
        let initialData = TestData(id: 1, name: "Initial")
        let newData = TestData(id: 2, name: "Updated")
        
        try await storage.save(initialData, name: fileName)
        let retrievedInitial: TestData = try await storage.retrieve(name: fileName)
        #expect(retrievedInitial == initialData)
        
        try await storage.save(newData, name: fileName)
        let retrievedUpdated: TestData = try await storage.retrieve(name: fileName)
        #expect(retrievedUpdated == newData)
        
        try await storage.remove(name: fileName)
    }
    
    @Test("DiskStorage: Remove file")
    func testDiskStorage_remove() async throws {
        let storage = DiskStorage(directory: .cachesDirectory)
        let fileName = "testFileRemove"
        let testData = TestData(id: 2, name: "TestRemove")
        
        try await storage.save(testData, name: fileName)
        try await storage.remove(name: fileName)
        
        do {
            let _: TestData = try await storage.retrieve(name: fileName)
            Issue.record("Should throw error")
        } catch let error as DiskStorageError {
            if case .fileNotFound = error {
                // Success
            } else {
                Issue.record("Wrong error case: \(error)")
            }
        } catch {
             Issue.record("Wrong error type: \(error)")
        }
    }
    
    // MARK: - SecuredPreferences Tests
    
    @Test("SecuredPreferences: Save and Read")
    func testSecuredPreferences_saveAndRead() async throws {
        let storage = SecuredPreferences()
        let key = "testSecureKey"
        let data = "secureData".data(using: .utf8)!
        
        // Cleanup first
        try? await storage.delete(forKey: key)
        
        try await storage.save(data: data, forKey: key)
        let retrieved = try await storage.read(forKey: key)
        
        #expect(retrieved == data)
        
        try await storage.delete(forKey: key)
    }
    
    @Test("SecuredPreferences: Overwrite value")
    func testSecuredPreferences_overwrite() async throws {
        let storage = SecuredPreferences()
        let key = "testSecureOverwrite"
        let initialData = "initial".data(using: .utf8)!
        let newData = "updated".data(using: .utf8)!
        
        // Cleanup
        try? await storage.delete(forKey: key)
        
        try await storage.save(data: initialData, forKey: key)
        let retrieved1 = try await storage.read(forKey: key)
        #expect(retrieved1 == initialData)
        
        try await storage.save(data: newData, forKey: key)
        let retrieved2 = try await storage.read(forKey: key)
        #expect(retrieved2 == newData)
        
        try await storage.delete(forKey: key)
    }
    
    @Test("SecuredPreferences: Read non-existent key")
    func testSecuredPreferences_notFound() async throws {
        let storage = SecuredPreferences()
        let key = "nonExistentKey"
        
        // Ensure it doesn't exist
        try? await storage.delete(forKey: key)
        
        let retrieved = try await storage.read(forKey: key)
        #expect(retrieved == nil)
    }
    
    // MARK: - DBStorage Tests
    
    @Test("DBStorage: Insert and Fetch", .tags(.important))
    func testDBStorage_insertAndFetch() async throws {
        let schema = Schema([TestModel.self])
        let storage = try DBStorage(schema: schema, isStoredInMemoryOnly: true)
        
        try await storage.perform { context in
            let model = TestModel(name: "Test Item", value: 42)
            context.insert(model)
            try context.save()
        }
        
        let retrievedName = try await storage.perform { context in
            let descriptor = FetchDescriptor<TestModel>()
            let results = try context.fetch(descriptor)
            return results.first?.name
        }
        
        #expect(retrievedName == "Test Item")
    }
    
    @Test("DBStorage: Delete model")
    func testDBStorage_delete() async throws {
        let schema = Schema([TestModel.self])
        let storage = try DBStorage(schema: schema, isStoredInMemoryOnly: true)
        
        try await storage.perform { context in
            let model = TestModel(name: "To Delete", value: 99)
            context.insert(model)
            try context.save()
        }
        
        try await storage.perform { context in
            var descriptor = FetchDescriptor<TestModel>()
            let results = try context.fetch(descriptor)
            
            if let modelToDelete = results.first {
                context.delete(modelToDelete)
                try context.save()
            }
        }
        
        let count = try await storage.perform { context in
            let descriptor = FetchDescriptor<TestModel>()
            return try context.fetch(descriptor).count
        }
        
        #expect(count == 0)
    }
    
    @Test("DBStorage: Save context manually")
    func testDBStorage_save() async throws {
        let schema = Schema([TestModel.self])
        let storage = try DBStorage(schema: schema, isStoredInMemoryOnly: true)
        
        try await storage.perform { context in
            let model = TestModel(name: "Manual Save", value: 123)
            context.insert(model)
            try context.save()
        }
        
        let count = try await storage.perform { context in
            let descriptor = FetchDescriptor<TestModel>()
            return try context.fetch(descriptor).count
        }
        
        #expect(count == 1)
    }
    
    @Test("DBStorage: Fetch with Predicate")
    func testDBStorage_fetchWithPredicate() async throws {
        let schema = Schema([TestModel.self])
        let storage = try DBStorage(schema: schema, isStoredInMemoryOnly: true)
        
        try await storage.perform { context in
            context.insert(TestModel(name: "Item 1", value: 10))
            context.insert(TestModel(name: "Item 2", value: 20))
            context.insert(TestModel(name: "Item 3", value: 30))
            try context.save()
        }
        
        let count = try await storage.perform { context in
            let descriptor = FetchDescriptor<TestModel>(
                predicate: #Predicate { $0.value > 15 }
            )
            return try context.fetch(descriptor).count
        }
        
        #expect(count == 2)
    }
}

extension Tag {
    @Tag static var important: Self
}

// MARK: - Helpers

struct TestData: Codable, Equatable, Sendable {
    let id: Int
    let name: String
}

@Model
final class TestModel {
    var name: String
    var value: Int
    
    init(name: String, value: Int) {
        self.name = name
        self.value = value
    }
}
