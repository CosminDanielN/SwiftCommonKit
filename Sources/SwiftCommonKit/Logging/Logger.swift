//
//  Logger.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import Foundation
import os

/// A lightweight wrapper around `os.Logger`.
/// Provides structured logging with subsystem and category support.
public struct Logger: Sendable {
    private let logger: os.Logger
    
    /// Initializes a new Logger instance.
    /// - Parameters:
    ///   - subsystem: The subsystem identifier (usually bundle ID).
    ///   - category: The specific category for this logger.
    public init(subsystem: String, category: String) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }
    
    /// Logs a debug message.
    /// - Parameter message: The message to log.
    public func debug(_ message: String) {
        logger.debug("\(message)")
    }
    
    /// Logs an informational message.
    /// - Parameter message: The message to log.
    public func info(_ message: String) {
        logger.info("\(message)")
    }
    
    /// Logs a warning message.
    /// - Parameter message: The message to log.
    public func warning(_ message: String) {
        logger.warning("\(message)")
    }
    
    /// Logs an error message.
    /// - Parameter message: The message to log.
    public func error(_ message: String) {
        logger.error("\(message)")
    }
    
    /// Logs a critical error message.
    /// - Parameter message: The message to log.
    public func critical(_ message: String) {
        logger.critical("\(message)")
    }
}
