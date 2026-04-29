//
//  StockDataQuotesRequest.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

struct StockDataQuotesRequest: StockRequest {
    typealias Response = [Quote]

    private static let endpoint = "https://api.stockdata.org/v1/data/quote"

    let symbols: [String]

    var url: URL {
        get throws {
            let apiKey = Secrets.stockDataAPIKey
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
    }

    func decode(_ data: Data) throws -> [Quote] {
        let response = try JSONDecoder().decode(
            StockDataQuotesResponse.self,
            from: data,
        )
        return response.quotes
    }

    func mockResponse() -> [Quote]? {
        StockDataQuotesResponse.mock(for: symbols).quotes
    }
}
