//
//  TwelveDataMockData.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/14/26.
//

import Foundation

/// Synthetic, stable values encoded in the provider's JSON shape, then decoded normally.
nonisolated enum TwelveDataMockData {
    static let stocks = [
        Stock(symbol: "AAPL", companyName: "Apple Inc."),
        Stock(symbol: "AMZN", companyName: "Amazon.com, Inc."),
        Stock(symbol: "GOOGL", companyName: "Alphabet Inc."),
        Stock(symbol: "META", companyName: "Meta Platforms, Inc."),
        Stock(symbol: "MSFT", companyName: "Microsoft Corporation"),
        Stock(symbol: "NVDA", companyName: "NVIDIA Corporation"),
        Stock(symbol: "TSLA", companyName: "Tesla, Inc."),
    ]

    private static let quotes: [String: (price: String, change: String)] = [
        "AAPL": ("204.18", "0.62"),
        "AMZN": ("186.54", "-0.34"),
        "GOOGL": ("171.13", "0.18"),
        "META": ("517.77", "-0.75"),
        "MSFT": ("391.44", "0.34"),
        "NVDA": ("115.74", "1.28"),
        "TSLA": ("169.28", "-1.12"),
    ]

    static func quote(for symbol: String) throws -> [String: String] {
        guard let quote = quotes[symbol] else {
            throw StockServiceError.missingMockData
        }
        return [
            "symbol": symbol,
            "close": quote.price,
            "percent_change": quote.change,
        ]
    }
}
