//
//  StockRequest.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

/// Defines how to build a stock-data request and decode its response.
///
/// Used internally by `StockService`; callers use `StockServicing` operations.
/// Mock payloads use the same response format and decoder as live data.
protocol StockRequest {
    /// The domain value produced by decoding the response payload.
    associatedtype Response

    /// Builds the authenticated URL for a live request.
    /// - Parameter apiKey: The provider's API key.
    /// - Returns: The request URL, including its query parameters.
    /// - Throws: An error if the key or request parameters cannot form a valid URL.
    func url(apiKey: String) throws -> URL

    /// Converts a provider payload into the request's domain response.
    /// - Parameter data: The raw response bytes, from the network or a mock.
    /// - Throws: An error if the payload reports a failure or cannot be decoded.
    func decode(_ data: Data) throws -> Response

    /// Supplies a local payload in the provider's response format.
    /// - Returns: Mock bytes, or `nil` when no mock is available. The default is `nil`.
    /// - Throws: An error if the mock payload cannot be produced.
    func mockData() throws -> Data?
}

extension StockRequest {
    func mockData() throws -> Data? {
        nil
    }
}
