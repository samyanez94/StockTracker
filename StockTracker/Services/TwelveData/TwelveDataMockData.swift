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

    static func quote(for symbol: String) throws -> [String: Any] {
        guard let quote = quotes[symbol] else {
            throw StockServiceError.missingMockData
        }
        guard let price = Double(quote.price), let percentChange = Double(quote.change) else {
            throw StockServiceError.invalidResponse
        }
        let previousClose = (price / (1 + percentChange / 100) * 100).rounded() / 100
        let open = (previousClose * 1.002 * 100).rounded() / 100
        let index = stocks.firstIndex { $0.symbol == symbol } ?? 0
        return [
            "symbol": symbol,
            "name": stocks[index].companyName,
            "currency": "USD",
            "close": quote.price,
            "percent_change": quote.change,
            "change": String(((price - previousClose) * 100).rounded() / 100),
            "open": String(open),
            "previous_close": String(previousClose),
            "volume": String(45_000_000 + index * 7_500_000),
            "average_volume": String(52_000_000 + index * 6_250_000),
            "low": String(min(open, price) * 0.99),
            "high": String(max(open, price) * 1.01),
            "fifty_two_week": [
                "low": String(price * 0.72),
                "high": String(price * 1.24),
            ],
        ]
    }
}
