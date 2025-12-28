//
//  DBStorage.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import Foundation
import SwiftData

/// A wrapper around SwiftData's ModelContainer and ModelContext.
/// Provides a safe, async interface for database operations.
public actor DBStorage: ModelActor {
    
    public nonisolated let modelContainer: ModelContainer
    public nonisolated let modelExecutor: any ModelExecutor
    
    public init(schema: Schema, isStoredInMemoryOnly: Bool = false) throws {
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly)
        self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        let context = ModelContext(modelContainer)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: context)
    }
    
    public init(container: ModelContainer) {
        self.modelContainer = container
        let context = ModelContext(container)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: context)
    }
    
    
    /// safe way to perform custom actions on the context
    public func perform<T: Sendable>(_ block: @Sendable (ModelContext) throws -> T) async throws -> T {
        try block(modelContext)
    }
}
