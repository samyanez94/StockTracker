//
//  StockDataQuoteRequest.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

struct StockDataQuoteRequest: StockRequest {
    typealias Response = [Quote]

    private static let endpoint = "https://api.stockdata.org/v1/data/quote"

    let symbols: [String]

    func url(apiKey: String) throws -> URL {
        guard !apiKey.isEmpty else {
            throw StockServiceError.missingAPIKey
        }
        guard let endpoint = URL(string: Self.endpoint) else {
            throw StockServiceError.invalidURL
        }
        var components = URLComponents(
            url: endpoint,
            resolvingAgainstBaseURL: false,
        )
        components?.queryItems = [
            URLQueryItem(
                name: "symbols",
                value: symbols.joined(separator: ","),
            ),
            URLQueryItem(
                name: "api_token",
                value: apiKey,
            ),
        ]
        guard let url = components?.url else {
            throw StockServiceError.invalidURL
        }
        return url
    }

    func decode(_ data: Data) throws -> [Quote] {
        let response = try JSONDecoder().decode(
            StockDataQuoteResponse.self,
            from: data,
        )
        return response.quotes
    }

    func mockResponse() -> [Quote]? {
        StockDataQuoteResponse.mock(for: symbols).quotes
    }
}
