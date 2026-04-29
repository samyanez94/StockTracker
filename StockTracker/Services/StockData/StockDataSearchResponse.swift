//
//  StockDataSearchResponse.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/28/26.
//

import Foundation

struct StockDataSearchResponse: Decodable {
    let data: [StockDataSearchResult]

    var stocks: [Stock] {
        data.map { $0.toStock() }
    }
}

struct StockDataSearchResult: Decodable {
    let symbol: String
    let name: String
}

extension StockDataSearchResult {
    func toStock() -> Stock {
        Stock(symbol: symbol, companyName: name)
    }
}

extension StockDataSearchResponse {
    private static let mockResults = [
        StockDataSearchResult(symbol: "AAPL", name: "Apple Inc."),
        StockDataSearchResult(symbol: "AMZN", name: "Amazon.com, Inc."),
        StockDataSearchResult(symbol: "GOOGL", name: "Alphabet Inc."),
        StockDataSearchResult(symbol: "META", name: "Meta Platforms, Inc."),
        StockDataSearchResult(symbol: "MSFT", name: "Microsoft Corporation"),
        StockDataSearchResult(symbol: "NVDA", name: "NVIDIA Corporation"),
        StockDataSearchResult(symbol: "TSLA", name: "Tesla, Inc."),
    ]

    static func mock(matching query: String) -> Self {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let results = mockResults.filter { result in
            result.symbol.localizedCaseInsensitiveContains(query)
                || result.name.localizedCaseInsensitiveContains(query)
        }
        return StockDataSearchResponse(data: results)
    }
}
