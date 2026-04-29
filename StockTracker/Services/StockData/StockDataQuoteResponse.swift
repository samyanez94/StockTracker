//
//  StockDataQuoteResponse.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

struct StockDataQuoteResponse: Decodable {
    let data: [StockDataQuote]

    var quotes: [Quote] {
        data.map { $0.toQuote() }
    }
}

struct StockDataQuote: Decodable {
    let ticker: String
    let price: Double
    let dayChange: Double

    enum CodingKeys: String, CodingKey {
        case ticker
        case price
        case dayChange = "day_change"
    }
}

extension StockDataQuote {
    func toQuote() -> Quote {
        Quote(
            symbol: ticker,
            price: price,
            percentChange: dayChange,
        )
    }
}

extension StockDataQuoteResponse {
    private static let mockQuotes = [
        "AAPL": StockDataQuote(ticker: "AAPL", price: 204.18, dayChange: Double.random(in: -1 ... 1)),
        "AMZN": StockDataQuote(ticker: "AMZN", price: 186.54, dayChange: Double.random(in: -1 ... 1)),
        "GOOGL": StockDataQuote(ticker: "GOOGL", price: 171.13, dayChange: Double.random(in: -1 ... 1)),
        "META": StockDataQuote(ticker: "META", price: 517.77, dayChange: Double.random(in: -1 ... 1)),
        "MSFT": StockDataQuote(ticker: "MSFT", price: 391.44, dayChange: Double.random(in: -1 ... 1)),
        "NVDA": StockDataQuote(ticker: "NVDA", price: 115.74, dayChange: Double.random(in: -1 ... 1)),
        "TSLA": StockDataQuote(ticker: "TSLA", price: 169.28, dayChange: Double.random(in: -1 ... 1)),
    ]

    static func mock(for symbols: [String]) -> Self {
        StockDataQuoteResponse(data: symbols.compactMap { mockQuotes[$0] })
    }
}
