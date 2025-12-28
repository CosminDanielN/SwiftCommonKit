//
//  DiskStorage.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import Foundation

/// Errors that can occur during disk storage operations.
public enum DiskStorageError: Error, Sendable {
    case fileNotFound
    case unhandledError(Error)
}

/// Concrete implementation of `FileStorage` using FileManager.
/// Implemented as an actor to offload I/O from the caller's context and ensure sequential access.
public actor DiskStorage: FileStorage {
    
    private let fileManager: FileManager
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let directory: FileManager.SearchPathDirectory
    
    /// Initializes the disk storage.
    /// - Parameters:
    ///   - fileManager: The file manager to use. Defaults to `.default`.
    ///   - directory: The search path directory to store files in. Defaults to `.documentDirectory`.
    public init(
        fileManager: FileManager = .default,
        directory: FileManager.SearchPathDirectory = .documentDirectory
    ) {
        self.fileManager = fileManager
        self.directory = directory
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
    
    public func save<T: Encodable & Sendable>(_ item: T, name: String) throws {
        guard let url = makeURL(for: name) else {
            throw DiskStorageError.fileNotFound // Or path error
        }
        
        do {
            let data = try encoder.encode(item)
            try data.write(to: url)
        } catch {
            throw DiskStorageError.unhandledError(error)
        }
    }
    
    public func retrieve<T: Decodable & Sendable>(name: String) throws -> T {
        guard let url = makeURL(for: name) else {
            throw DiskStorageError.fileNotFound
        }
        
        guard fileManager.fileExists(atPath: url.path) else {
            throw DiskStorageError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        } catch {
            throw DiskStorageError.unhandledError(error)
        }
    }
    
    public func remove(name: String) throws {
        guard let url = makeURL(for: name) else {
            throw DiskStorageError.fileNotFound
        }
        
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }
        
        do {
            try fileManager.removeItem(at: url)
        } catch {
            throw DiskStorageError.unhandledError(error)
        }
    }
    
    private func makeURL(for name: String) -> URL? {
        guard let url = fileManager.urls(for: directory, in: .userDomainMask).first else {
            return nil
        }
        
        return url.appendingPathComponent(name)
    }
}
