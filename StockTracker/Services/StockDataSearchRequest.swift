//
//  StockDataSearchRequest.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/28/26.
//

import Foundation

nonisolated struct StockDataSearchRequest: StockRequest {
    typealias Response = [Stock]

    private static let endpoint = "https://api.stockdata.org/v1/entity/search"

    let query: String

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
                    name: "search",
                    value: query,
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

    func decode(_ data: Data) throws -> [Stock] {
        let response = try JSONDecoder().decode(
            StockDataSearchResponse.self,
            from: data,
        )
        return response.stocks
    }

    func mockResponse() -> [Stock]? {
        StockDataSearchResponse.mock(matching: query).stocks
    }
}
