//
//  LoggerTests.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import Testing
@testable import SwiftCommonKit

@Suite("Logger Tests")
struct LoggerTests {
    
    @Test("Logger initializes correctly")
    func testLoggerInitialization() {
        let logger = Logger(subsystem: "com.test.app", category: "Test")
        #expect(logger != nil)
    }
    
    // Note: OSLog writes to the system log, which is hard to verify in unit tests
    // without using private APIs or complex interception. 
    // These tests primarily verify the API surface and crash-safety.
    
    @Test("Logger logs debug message")
    func testLogger_debug() {
        let logger = Logger(subsystem: "com.test.app", category: "Test")
        logger.debug("Debug message")
    }
    
    @Test("Logger logs info message")
    func testLogger_info() {
        let logger = Logger(subsystem: "com.test.app", category: "Test")
        logger.info("Info message")
    }
    
    @Test("Logger logs warning message")
    func testLogger_warning() {
        let logger = Logger(subsystem: "com.test.app", category: "Test")
        logger.warning("Warning message")
    }
    
    @Test("Logger logs error message")
    func testLogger_error() {
        let logger = Logger(subsystem: "com.test.app", category: "Test")
        logger.error("Error message")
    }
    
    @Test("Logger logs critical message")
    func testLogger_critical() {
        let logger = Logger(subsystem: "com.test.app", category: "Test")
        logger.critical("Critical message")
    }
}
