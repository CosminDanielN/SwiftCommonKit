//
//  NetworkTests.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import Testing
import Foundation
@testable import SwiftCommonKit

@Suite("Network Tests", .serialized)
class NetworkTests {
    
    var client: URLSessionNetworkClient!
    var session: URLSession!
    
    init() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        client = URLSessionNetworkClient(baseURL: URL(string: "https://api.example.com")!, session: session)
    }
    
    deinit {
        client = nil
        session = nil
        MockURLProtocol.requestHandler = nil
    }
    
    @Test("Network Request: Success")
    func testRequest_success() async throws {
        let expectedData = TestData(id: 1, name: "Test")
        let endpoint = Endpoint(path: "/test")
        
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url.path == "/test" else {
                throw NetworkError.badURL
            }
            
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = try JSONEncoder().encode(expectedData)
            return (response, data)
        }
        
        let result: TestData = try await client.request(endpoint)
        #expect(result == expectedData)
    }
    
    @Test("Network Request: Failure 404")
    func testRequest_failure_404() async {
        let endpoint = Endpoint(path: "/notfound")
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        do {
            let _: TestData = try await client.request(endpoint)
            Issue.record("Should throw error")
        } catch NetworkError.requestFailed(let statusCode) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }
    
    @Test("Network Request: Decoding Error")
    func testRequest_decodingError() async {
        let endpoint = Endpoint(path: "/badData")
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = "invalid json".data(using: .utf8)!
            return (response, data)
        }
        
        do {
            let _: TestData = try await client.request(endpoint)
            Issue.record("Should throw error")
        } catch NetworkError.decodingError {
            // Success
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }
}

// MARK: - MockURLProtocol

class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            Issue.record("Handler is unavailable.")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
