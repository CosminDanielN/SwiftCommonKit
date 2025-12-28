//
//  URLSessionNetworkClient.swift
//  SwiftCommonKit
//
//  Created by Lens Team on 28.12.2025.
//

import Foundation

/// Concrete implementation of `NetworkClient` using `URLSession`.
/// Sendable as it holds immutable state (URLSession is thread-safe).
public final class URLSessionNetworkClient: NetworkClient {
    private let baseURL: URL
    private let session: URLSession
    
    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    public func request<T: Decodable>(_ endpoint: Endpoint, decoder: JSONDecoder) async throws -> T {
        guard let url = makeURL(for: endpoint) else {
            throw NetworkError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
            }
            
            return try decoder.decode(T.self, from: data)
        } catch {
            if let networkError = error as? NetworkError {
                throw networkError
            }
            
            if let decodingError = error as? DecodingError {
                print("Decoding Error: \(decodingError)")
                throw NetworkError.decodingError
            }
            
            throw NetworkError.unknown(error)
        }
    }
    
    private func makeURL(for endpoint: Endpoint) -> URL? {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true)
        if !endpoint.queryItems.isEmpty {
            components?.queryItems = endpoint.queryItems
        }
        return components?.url
    }
}
