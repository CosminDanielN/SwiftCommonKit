//
//  LoggerTests.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import XCTest
@testable import SwiftCommonKit

final class LoggerTests: XCTestCase {
    
    func testLoggerInitialization() {
        let logger = Logger(subsystem: "com.test.app", category: "Test")
        XCTAssertNotNil(logger)
    }
    
    // Note: OSLog writes to the system log, which is hard to verify in unit tests
    // without using private APIs or complex interception. 
    // These tests primarily verify the API surface and crash-safety.
    
    func testLogger_debug() {
        let logger = Logger(subsystem: "com.test.app", category: "Test")
        logger.debug("Debug message")
    }
    
    func testLogger_info() {
        let logger = Logger(subsystem: "com.test.app", category: "Test")
        logger.info("Info message")
    }
    
    func testLogger_warning() {
        let logger = Logger(subsystem: "com.test.app", category: "Test")
        logger.warning("Warning message")
    }
    
    func testLogger_error() {
        let logger = Logger(subsystem: "com.test.app", category: "Test")
        logger.error("Error message")
    }
    
    func testLogger_critical() {
        let logger = Logger(subsystem: "com.test.app", category: "Test")
        logger.critical("Critical message")
    }
}
