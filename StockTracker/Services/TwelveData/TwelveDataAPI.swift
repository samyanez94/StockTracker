//
//  TwelveDataAPI.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/14/26.
//

import Foundation

/// Shared URL construction and error-envelope decoding for Twelve Data requests.
nonisolated enum TwelveDataAPI {

    /// Builds an HTTPS URL on `api.twelvedata.com` with API-key authentication.
    /// - Parameters:
    ///   - path: The endpoint path, including its leading slash.
    ///   - queryItems: Endpoint parameters, excluding the API key.
    ///   - apiKey: A nonblank Twelve Data API key.
    /// - Returns: The endpoint URL with an appended `apikey` query item.
    /// - Throws: `StockServiceError.missingAPIKey` for a blank key, or
    ///   `StockServiceError.invalidURL` if URL construction fails.
    static func url(
        path: String,
        queryItems: [URLQueryItem],
        apiKey: String
    ) throws -> URL {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw StockServiceError.missingAPIKey
        }
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.twelvedata.com"
        components.path = path
        components.queryItems = queryItems + [URLQueryItem(name: "apikey", value: apiKey)]
        guard let url = components.url else {
            throw StockServiceError.invalidURL
        }
        return url
    }

    /// Decodes a successful payload or throws the provider's reported error.
    /// - Parameters:
    ///   - type: The expected successful response type.
    ///   - data: JSON bytes returned by Twelve Data or a mock.
    /// - Returns: The decoded response value.
    /// - Throws: `StockServiceError.apiError` for an API error envelope, or a decoding
    ///   error if the payload does not match the expected format.
    static func decode<Value: Decodable>(
        _ type: Value.Type,
        from data: Data
    ) throws -> Value {
        try JSONDecoder().decode(TwelveDataResult<Value>.self, from: data).value()
    }
}
