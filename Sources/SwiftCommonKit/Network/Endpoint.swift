//
//  Endpoint.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import Foundation

/// Defines the details of a network request.
public struct Endpoint: Sendable {
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]
    public let queryItems: [URLQueryItem]
    
    public init(
        path: String,
        method: HTTPMethod = .GET,
        headers: [String: String] = [:],
        queryItems: [URLQueryItem] = []
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
    }
}

/// HTTP Methods
public enum HTTPMethod: String, Sendable {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}

/// Errors occurring during network requests.
public enum NetworkError: Error, Sendable {
    case badURL
    case requestFailed(statusCode: Int)
    case decodingError
    case unknown(Error)
}

/// Protocol defining a network client.
/// Non-isolated to support background networking.
public protocol NetworkClient: Sendable {
    /// Performs a network request.
    /// - Parameters:
    ///   - endpoint: The endpoint definition.
    ///   - decoder: JSONDecoder to use.
    /// - Returns: Decoded object.
    func request<T: Decodable>(_ endpoint: Endpoint, decoder: JSONDecoder) async throws -> T
}

public extension NetworkClient {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        try await request(endpoint, decoder: JSONDecoder())
    }
}
