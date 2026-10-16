//
//  MockStockService.swift
//  StockTrackerTests
//
//  Created by Samuel Yanez on 10/16/26.
//

import Foundation
@testable import StockTracker

actor MockStockService: StockServicing {
    let quotes: [Quote]
    let searchResults: [Stock]
    let error: Error?
    let delay: Duration
    private(set) var fetchCount = 0

    init(
        quotes: [Quote] = [],
        searchResults: [Stock] = [],
        error: Error? = nil,
        delay: Duration = .zero
    ) {
        self.quotes = quotes
        self.searchResults = searchResults
        self.error = error
        self.delay = delay
    }

    func fetchQuotes(symbols _: [String]) async throws -> [Quote] {
        try await prepareResponse()
        return quotes
    }

    func fetchTimeSeries(symbol _: String) async throws -> [StockPricePoint] {
        try await prepareResponse()
        return []
    }

    func searchStocks(query: String) async throws -> [Stock] {
        try await prepareResponse()
        return searchResults.filter {
            $0.symbol.localizedCaseInsensitiveContains(query)
                || $0.companyName.localizedCaseInsensitiveContains(query)
        }
    }

    private func prepareResponse() async throws {
        fetchCount += 1
        if delay > .zero {
            try await Task.sleep(for: delay)
        }
        if let error {
            throw error
        }
    }
}
