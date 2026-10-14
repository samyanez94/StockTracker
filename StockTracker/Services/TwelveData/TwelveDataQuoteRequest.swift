//
//  TwelveDataQuoteRequest.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/14/26.
//

import Foundation

struct TwelveDataQuoteRequest: StockRequest {
    let symbols: [String]

    func url(apiKey: String) throws -> URL {
        try TwelveDataAPI.url(
            path: "/quote",
            queryItems: [
                URLQueryItem(name: "symbol", value: symbols.joined(separator: ",")),
            ],
            apiKey: apiKey
        )
    }

    func decode(_ data: Data) throws -> [Quote] {
        guard !symbols.isEmpty else {
            return []
        }
        if symbols.count == 1 {
            let response = try TwelveDataAPI.decode(TwelveDataQuoteResponse.self, from: data)
            guard response.symbol == symbols[0] else {
                throw StockServiceError.invalidResponse
            }
            return try [response.toQuote()]
        }
        let responses = try TwelveDataAPI.decode(
            [String: TwelveDataResult<TwelveDataQuoteResponse>].self, from: data
        )
        // Fail the refresh on partial errors so the controller preserves existing quotes.
        return try symbols.map { symbol in
            guard let result = responses[symbol] else {
                throw StockServiceError.invalidResponse
            }
            let response = try result.value()
            guard response.symbol == symbol else {
                throw StockServiceError.invalidResponse
            }
            return try response.toQuote()
        }
    }

    func mockData() throws -> Data? {
        let responses = try symbols.map {
            try TwelveDataMockData.quote(for: $0)
        }
        if symbols.count == 1 {
            return try JSONSerialization.data(withJSONObject: responses[0])
        }
        let batch = Dictionary(
            zip(symbols, responses),
            uniquingKeysWith: { first, _ in first }
        )
        return try JSONSerialization.data(withJSONObject: batch)
    }
}
